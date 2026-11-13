# audio

`audio <query>` lists PipeWire outputs (sinks) and inputs (sources), defaults first. Type
`input` or `output` to filter by kind.

- Enter makes the device the default.
- Ctrl+K: mute/unmute, volume 25/50/75/100%.

```json
{"title": "Built-in Audio Analog Stereo", "subtitle": "output · default", "hint": "40%", "action": {"run": "wpctl set-default 49"}}
{"title": "WH-1000XM4", "subtitle": "output", "hint": "muted · 55%", "action": {"run": "wpctl set-default 71"}}
{"title": "Built-in Audio Analog Stereo", "subtitle": "input · default", "hint": "100%", "action": {"run": "wpctl set-default 50"}}
```

Needs `wpctl` (WirePlumber). Parses `wpctl status`; tested with a captured status (Video,
Filters and Streams sections are ignored) and `jq`. Switching devices needs a desktop with
PipeWire running.
