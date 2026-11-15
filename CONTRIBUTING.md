# Adding a plugin

1. Make a folder `<name>/` with the executable `<name>/<name>` (same name, any language, shebang on line 1).
2. `git add --chmod=+x <name>/<name>` so the executable bit survives.
3. Headers in the first 30 lines: zunder's `name`, `prefix`, `glyph`, `mode` ([docs](https://github.com/elyesghazel/zunder/blob/main/docs/plugins.md)), plus:
   `# @zunder.description <one line>` (required), `# @zunder.requires <bin> ...`, `# @zunder.platforms linux macos`, `# @zunder.setting <key> "<help>"` (one per line, reaches the script as `ZUNDER_<KEY>`),
   `# @zunder.color #rrggbb` (the card and glyph colour in zunder; pick one no other plugin uses, mid-tone so it reads on dark and light themes).
4. Add `<name>/README.md` with a short output example or a `screenshot.png`, and say what you could not test.
5. Test with a few queries: `./<name>/<name> "query" | jq .`. Keep each call under 100 ms or cache.
6. Run `python3 scripts/build-index.py --check` and `shellcheck` on sh/bash plugins; CI runs both on your PR.
7. Windows variant (optional): `<name>/<name>.ps1` for Windows PowerShell 5.1 with the same `name`, `prefix`, `glyph`, `color` and `mode` headers and its own `requires`. Keep it ASCII only (write glyphs as `\uXXXX` in headers and `[char]0x...` in code), set `[Console]::OutputEncoding` to UTF-8, and remember `run` actions go through `cmd /C`. Add it to `PS1` in `scripts/test-plugins.py` with a query that only lists; CI runs it on `windows-latest`. A Python plugin that works on Windows just adds `windows` to its platforms.
8. Don't edit `index.json`: CI rebuilds it on every push to `main`.
