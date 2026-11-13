# wifi

`wifi <query>` lists nearby networks from NetworkManager, connected one first, then by signal.

- Enter on a saved network connects, on the connected one disconnects.
- Enter on a new secured network opens `nmcli --ask device wifi connect` in your terminal, which
  asks for the password.
- Ctrl+K: copy the SSID, forget a saved network.
- `Rescan` refreshes the list (the plugin itself never rescans, so each keystroke stays fast).

```json
{"title": "Home", "subtitle": "connected · Enter disconnects · WPA2", "hint": "▂▄▆█ 82%", "action": {"run": "nmcli connection down id Home"}}
{"title": "Neighbour 5G", "subtitle": "password in terminal · WPA2 WPA3", "hint": "▂▄▆ 61%", "action": {"term": "nmcli --ask device wifi connect 'Neighbour 5G'"}}
{"title": "FreeWifi", "subtitle": "open network", "hint": "▂▄▆ 55%", "action": {"run": "nmcli device wifi connect FreeWifi"}}
```

Needs `nmcli`. Tested with a fake `nmcli` (escaped `:` in SSIDs, duplicate BSSIDs, open/secured,
hidden networks) and `jq`, ~50 ms per call. Connecting for real needs a machine with Wi-Fi.
