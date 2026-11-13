#!/usr/bin/env python3
"""Build index.json from the plugin headers, or check them with --check.

Each plugin lives in <name>/<name>. Headers are read the way zunder reads them
(src/providers/plugins.rs): the first 30 lines of the first 4096 bytes, any line
containing `@zunder.<key> <value>`.

    scripts/build-index.py            write index.json
    scripts/build-index.py --check    validate every plugin, exit 1 on errors
    scripts/build-index.py --shell    print the sh/bash plugins (for shellcheck)
"""
import hashlib
import json
import os
import re
import shlex
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHELLS = {"sh", "bash", "dash", "ksh"}


def unescape(s):
    """`\\uf120` -> the char, same as zunder."""
    m = re.fullmatch(r"\\u([0-9a-fA-F]+)", s)
    if m:
        try:
            return chr(int(m.group(1), 16))
        except (ValueError, OverflowError):
            pass
    return s


def headers(path):
    with open(path, "rb") as f:
        head = f.read(4096).decode("utf-8", "replace")
    out = []
    for line in head.splitlines()[:30]:
        _, sep, rest = line.partition("@zunder.")
        if not sep:
            continue
        parts = rest.split(None, 1)
        if parts:
            out.append((parts[0], parts[1].strip() if len(parts) > 1 else ""))
    return out


def shebang(path):
    with open(path, "rb") as f:
        first = f.readline().decode("utf-8", "replace").strip()
    return first[2:].strip() if first.startswith("#!") else None


def interpreter(path):
    """`/usr/bin/env bash` -> bash, `/bin/sh` -> sh."""
    sb = shebang(path)
    if not sb:
        return None
    words = sb.split()
    prog = os.path.basename(words[0])
    if prog == "env":
        words = [w for w in words[1:] if not w.startswith("-")]
        prog = os.path.basename(words[0]) if words else ""
    return prog


def plugin_dirs():
    return sorted(
        d for d in os.listdir(ROOT)
        if os.path.isdir(os.path.join(ROOT, d)) and not d.startswith(".") and d != "scripts"
    )


def last_commit(name):
    r = subprocess.run(["git", "log", "-1", "--format=%H", "--", f"{name}/"],
                       cwd=ROOT, capture_output=True, text=True, check=True)
    return r.stdout.strip()


def entry(name):
    path = os.path.join(ROOT, name, name)
    p = {"name": name, "title": name, "description": "", "prefix": name,
         "glyph": "", "mode": "search", "file": f"{name}/{name}",
         "commit": last_commit(name), "sha256": "",
         "requires": [], "platforms": [], "settings": []}
    for key, value in headers(path):
        if key == "name":
            p["title"] = value
        elif key == "prefix":
            p["prefix"] = value
        elif key == "glyph":
            p["glyph"] = unescape(value)
        elif key == "mode":
            p["mode"] = "command" if value == "command" else "search"
        elif key == "description":
            p["description"] = value
        elif key in ("requires", "platforms"):
            p[key] += [v for v in re.split(r"[\s,]+", value) if v]
        elif key == "setting":
            k, _, help_ = value.partition(" ")
            help_ = help_.strip()
            try:
                help_ = " ".join(shlex.split(help_))
            except ValueError:
                pass
            if k:
                p["settings"].append({"key": k, "help": help_})
    with open(path, "rb") as f:
        p["sha256"] = hashlib.sha256(f.read()).hexdigest()
    return p


def check(name):
    errors = []
    d = os.path.join(ROOT, name)
    path = os.path.join(d, name)
    if not os.path.isfile(path):
        others = [f for f in os.listdir(d) if f not in ("README.md", "screenshot.png")]
        hint = f" (found {', '.join(others)})" if others else ""
        return [f"{name}/: no executable named {name}{hint}; folder name must equal file name"]
    if not os.access(path, os.X_OK):
        errors.append(f"{name}/{name}: not executable (git add --chmod=+x {name}/{name})")
    if shebang(path) is None:
        errors.append(f"{name}/{name}: no shebang on the first line")
    hs = dict(headers(path))
    if not hs.get("description"):
        errors.append(f"{name}/{name}: missing `# @zunder.description ...` in the first 30 lines")
    if hs.get("mode", "search") not in ("search", "command"):
        errors.append(f"{name}/{name}: mode must be search or command")
    if not os.path.isfile(os.path.join(d, "README.md")):
        errors.append(f"{name}/: missing README.md")
    return errors


def main():
    args = sys.argv[1:]
    names = plugin_dirs()
    if "--shell" in args:
        for n in names:
            path = os.path.join(ROOT, n, n)
            if os.path.isfile(path) and interpreter(path) in SHELLS:
                print(f"{n}/{n}")
        return 0
    if "--check" in args:
        errors = [e for n in names for e in check(n)]
        for e in errors:
            print(f"::error::{e}" if os.environ.get("GITHUB_ACTIONS") else e, file=sys.stderr)
        print(f"{len(names)} plugins, {len(errors)} errors")
        return 1 if errors else 0
    index = {"version": 1, "plugins": [entry(n) for n in names]}
    with open(os.path.join(ROOT, "index.json"), "w", encoding="utf-8") as f:
        json.dump(index, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"index.json: {len(names)} plugins")
    return 0


if __name__ == "__main__":
    sys.exit(main())
