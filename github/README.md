# github

`gh <words>` searches your repos by name and description. Enter opens the repo.
Ctrl+K: copy the URL or SSH clone URL, open issues or pull requests.

Settings:

- `token`: a GitHub token. Optional; without it the plugin uses the `gh` CLI (`gh auth login`).
- `limit`: how many repos to load, default 100.

The list is cached in `~/.cache/zunder/github-repos.json` for 10 minutes; after that the old
list is shown and refreshed in the background, so typing never waits on the network.

```json
{"title": "elyesghazel/zunder", "subtitle": "One prompt for your apps and your windows: a terminal-styled launcher and ALT+TAB switcher with live thumbnails for Hyprland", "hint": "★ 8", "action": {"open": "https://github.com/elyesghazel/zunder"}}
{"title": "elyesghazel/zunder-site", "subtitle": "", "hint": "private", "action": {"open": "https://github.com/elyesghazel/zunder-site"}}
```

Tested headless against the real API through `gh` and with a bad token (error shown as the
result): ~750 ms on the first call, ~80 ms from cache. Opening links needs a desktop.
