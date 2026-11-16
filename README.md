# zunder-plugins

Plugins for [zunder](https://github.com/elyesghazel/zunder). Install one with:

```sh
zunder plugin install <name>
```

One folder per plugin: the executable (same name as the folder), a `README.md` and optionally a
`screenshot.png`. CI builds `index.json` from the headers, which is what `zunder plugin` reads.

| Plugin | Prefix | What it does | Platforms |
|--------|--------|--------------|-----------|
| [agenda](agenda) | `cal` | Your next events from an ICS calendar URL | Linux, macOS, Windows |
| [audio](audio) | `audio` | Switch the default audio output or input (wpctl) | Linux |
| [bluetooth](bluetooth) | `bt` | Connect and disconnect paired Bluetooth devices (bluetoothctl) | Linux |
| [color](color) | `color` | Pick a colour from the screen, copy it as hex, rgb or hsl | Linux |
| [github](github) | `gh` | Your repos, PRs, review requests, issues and notifications | Linux, macOS, Windows |
| [ip](ip) | command | Copy your local IPv4 address | Linux, Windows |
| [kill](kill) | `kill` | Search your processes, sorted by CPU, Enter stops one | Linux, macOS, Windows |
| [pass](pass) | `pass` | Copy passwords or usernames from pass or gopass | Linux |
| [quicklinks](quicklinks) | `q` | Search sites with a keyword, e.g. `q yt lofi` | Linux, macOS, Windows |
| [screenshot](screenshot) | `shot` | Screenshot a region, window or screen, saved and copied | Linux, Windows |
| [systemd](systemd) | `sd` | Start, stop or restart systemd services (Windows: Windows services) | Linux, Windows |
| [wifi](wifi) | `wifi` | Connect to Wi-Fi networks (nmcli, Windows: netsh) | Linux, Windows |

On Windows, plugins with a `<name>.ps1` next to them install that file instead; the Python ones
need Python (`py`).

Adding a plugin: see [CONTRIBUTING.md](CONTRIBUTING.md).
