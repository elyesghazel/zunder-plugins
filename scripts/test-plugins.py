#!/usr/bin/env python3
"""Run plugins with sample queries and check every line they print, the way zunder reads it.

    scripts/test-plugins.py      on Windows: every .ps1 variant and the Python plugins
                                 elsewhere: the Python plugins

.ps1 files run like zunder runs them on Windows (powershell -NoProfile -ExecutionPolicy Bypass
-File), Python plugins with this interpreter. The queries only list things: nothing here
connects, stops or starts anything.
"""
import json
import os
import re
import subprocess
import sys
import tempfile
import time
import datetime as dt

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WINDOWS = os.name == "nt"
ACTIONS = {"run", "term", "open", "copy", "focus", "fill", "window"}
TEXT = {"title", "subtitle", "hint", "glyph", "icon", "image", "preview"}
IPV4 = re.compile(r"(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})")

# plugin -> [(query, minimum number of rows)]; None as the query means command mode (no args)
PS1 = {
    "wifi": [("", 1), ("zzzz-no-such-network", 0)],
    "kill": [("", 1), ("python", 1)],  # this test runs in python, so there is one
    "ip": [(None, 0)],
    "systemd": [("", 10), ("windows", 1), ("zzzz-no-such-service", 0)],
    "screenshot": [("", 4), ("region", 1), ("folder", 1)],
}
PYTHON = {
    "quicklinks": [("", 3), ("yt lofi", 1)],
    "agenda": [("", 1), ("caf", 1)],
    # no token in CI: either repos or a readable error, both are fine
    "github": [("", 0), ("pr", 0), ("review", 0), ("issues", 0), ("notif", 0), ("zunder", 0)],
}


def check_action(where, a):
    keys = ACTIONS & set(a)
    if len(keys) != 1:
        return [f"{where}: needs exactly one of {sorted(ACTIONS)}, has {sorted(a)}"]
    k = keys.pop()
    v = a[k]
    if k == "window":
        return [] if isinstance(v, dict) and "address" in v else [f"{where}: bad window action {v!r}"]
    if not isinstance(v, str) or not v:
        return [f"{where}: {k} must be a non-empty string"]
    if k in ("run", "term") and "\n" in v:
        return [f"{where}: {k} command has a newline"]
    return []


def check_row(where, row):
    if not isinstance(row, dict):
        return [f"{where}: not a JSON object"]
    errors = []
    if not isinstance(row.get("title"), str) or not row["title"]:
        errors.append(f"{where}: missing title")
    for k in TEXT & set(row):
        if not isinstance(row[k], str):
            errors.append(f"{where}: {k} must be a string, got {type(row[k]).__name__}")
    if "action" in row:
        errors += check_action(f"{where} action", row["action"]) if isinstance(row["action"], dict) \
            else [f"{where}: action must be an object"]
    for i, a in enumerate(row.get("actions", [])):
        if not isinstance(a, dict) or not isinstance(a.get("title"), str):
            errors.append(f"{where} actions[{i}]: needs a title")
        else:
            errors += check_action(f"{where} actions[{i}]", a)
    return errors


def run(cmd, query, env):
    args = cmd + ([] if query is None else [query])
    start = time.monotonic()
    r = subprocess.run(args, capture_output=True, timeout=60, env=env, cwd=ROOT)
    return r, time.monotonic() - start


def test(name, cmd, cases, env):
    errors = []
    for query, minimum in cases:
        label = f"{name} {query!r}" if query is not None else f"{name} (command)"
        try:
            r, took = run(cmd, query, env)
        except subprocess.TimeoutExpired:
            errors.append(f"{label}: timed out")
            continue
        try:
            out = r.stdout.decode("utf-8")
        except UnicodeDecodeError as e:
            errors.append(f"{label}: stdout is not UTF-8 ({e})")
            continue
        err = r.stderr.decode("utf-8", "replace").strip()
        lines = [l for l in out.splitlines() if l.strip()]
        print(f"{label}: exit {r.returncode}, {len(lines)} lines, {took * 1000:.0f} ms")
        for l in lines[:3]:
            print(f"    {l[:160]}")
        if query is None:  # command mode: ip prints the address it copied
            if r.returncode != 0:
                errors.append(f"{label}: exit {r.returncode}: {err}")
            elif not (len(lines) == 1 and IPV4.fullmatch(lines[0].strip())):
                errors.append(f"{label}: expected one IPv4 address, got {lines!r}")
            continue
        if r.returncode != 0:
            # zunder shows the last stderr line when a plugin fails without output
            if lines or not err:
                errors.append(f"{label}: exit {r.returncode} with {len(lines)} lines, stderr {err!r}")
            elif minimum:
                errors.append(f"{label}: failed: {err.splitlines()[-1]}")
            else:
                print(f"    error shown to the user: {err.splitlines()[-1]}")
            continue
        if err:
            print(f"    stderr: {err[:300]}")
        for i, l in enumerate(lines):
            try:
                row = json.loads(l)
            except ValueError:
                errors.append(f"{label} line {i + 1}: not JSON: {l[:120]}")
                continue
            errors += check_row(f"{label} line {i + 1}", row)
        if len(lines) < minimum:
            errors.append(f"{label}: {len(lines)} rows, expected at least {minimum}")
    return errors


def sample_calendar(folder):
    """A calendar with an event tomorrow, non-ASCII on purpose (Windows code pages)."""
    day = (dt.date.today() + dt.timedelta(days=1)).strftime("%Y%m%d")
    path = os.path.join(folder, "sample.ics")
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write("\r\n".join([
            "BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//zunder-plugins//test//EN",
            "BEGIN:VEVENT", "UID:test-1@zunder", f"DTSTART:{day}T090000Z", f"DTEND:{day}T100000Z",
            "SUMMARY:Café with Zoë ☕", "LOCATION:Zürich", "END:VEVENT", "END:VCALENDAR", ""]))
    return "file:" + ("///" if WINDOWS else "//") + path.replace("\\", "/")


def main():
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    with tempfile.TemporaryDirectory() as tmp:
        env = {k: v for k, v in os.environ.items() if not k.startswith("ZUNDER_")}
        env["XDG_CACHE_HOME"] = tmp
        errors = []
        if WINDOWS:
            for name, cases in PS1.items():
                path = os.path.join(ROOT, name, f"{name}.ps1")
                cmd = ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", path]
                errors += test(name, cmd, cases, env)
        for name, cases in PYTHON.items():
            e = dict(env)
            if name == "agenda":
                e["ZUNDER_URL"] = sample_calendar(tmp)
            errors += test(name, [sys.executable, os.path.join(ROOT, name, name)], cases, e)
    for e in errors:
        print(f"::error::{e}" if os.environ.get("GITHUB_ACTIONS") else e, file=sys.stderr)
    print(f"{len(errors)} errors")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
