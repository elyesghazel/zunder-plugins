# color

`color` shows "Pick a colour" and your recent picks.

- Enter on "Pick a colour" runs `hyprpicker`; click anywhere and the hex is copied and saved to
  the history.
- Each colour shows a swatch in the preview pane, plus hex, rgb and hsl. Enter copies the hex,
  Ctrl+K copies rgb, hsl or the hex without `#`.
- Type a hex (`#3a86ff`, `f80`) to see that colour and copy its other formats.

```json
{"title": "#3a86ff", "subtitle": "recent", "hint": "rgb(58, 134, 255)", "image": "~/.cache/zunder/color/3a86ff.png", "preview": "#3a86ff\nrgb(58, 134, 255)\nhsl(217, 100%, 61%)", "action": {"copy": "#3a86ff"}}
```

History and swatches (96×96 PNGs, written with the Python stdlib) live in
`~/.cache/zunder/color/`.

Needs `hyprpicker` and `wl-copy`. Tested with a fake `hyprpicker` (history, PNG swatch checked
with `file` and by eye) and `jq`, ~60 ms per call. Picking for real needs Hyprland.
