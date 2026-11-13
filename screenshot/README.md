# screenshot

`shot` offers Region, Window, Screen, All screens and Open folder. The capture is saved as
`YYYY-MM-DD_HH-MM-SS.png` and copied to the clipboard as an image.

- Region: drag a rectangle with `slurp`.
- Window: click one of the windows on the visible workspaces (boxes from `hyprctl clients`).
- Screen: the focused monitor. All screens: every monitor in one image.
- Esc in slurp cancels without saving anything.

Setting `dir`: where to save, default `$XDG_PICTURES_DIR/Screenshots` or
`~/Pictures/Screenshots`.

```json
{"title": "Region", "subtitle": "drag a rectangle", "action": {"run": "\"/home/you/.config/zunder/plugins/screenshot\" --take region"}}
{"title": "Open folder", "subtitle": "/home/you/Pictures/Screenshots", "action": {"open": "/home/you/Pictures/Screenshots"}}
```

Needs `grim`, `slurp`, `wl-copy`, `jq` and `hyprctl` (Window and Screen are Hyprland-specific;
Region and All screens work on any wlroots compositor). Tested with fake `grim`, `slurp` and
`hyprctl` (geometry, window filtering by visible workspace, file naming) and `shellcheck`. The
actual capture needs a Wayland desktop.
