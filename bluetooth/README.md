# bluetooth

`bt <query>` lists paired devices, connected ones first.

- Enter connects (powering the adapter on first) or disconnects.
- The first row turns Bluetooth on or off.
- Ctrl+K: copy the address, unpair.
- No paired devices: Enter opens `bluetoothctl` in your terminal to pair one.

```json
{"title": "Turn Bluetooth off", "subtitle": "powered", "action": {"run": "bluetoothctl power off"}}
{"title": "MX Master 3", "subtitle": "connected · Enter disconnects", "hint": "F4:4E:FC:AA:BB:CC", "action": {"run": "bluetoothctl disconnect F4:4E:FC:AA:BB:CC"}}
{"title": "WH-1000XM4", "subtitle": "paired", "hint": "38:18:4C:11:22:33", "action": {"run": "bluetoothctl power on && bluetoothctl connect 38:18:4C:11:22:33"}}
```

Needs `bluetoothctl` (BlueZ). Works with BlueZ 5.65+ (`devices Paired`) and falls back to
`paired-devices` on older versions. Tested with a fake `bluetoothctl` and `jq`; connecting a real
device needs a machine with a Bluetooth adapter.
