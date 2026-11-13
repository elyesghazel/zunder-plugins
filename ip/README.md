# ip

Command plugin: search "Copy Local IP", Enter copies your local IPv4 address (the source address
of the default route) and shows a notification.

```
$ ip -4 -o route get 1.1.1.1
1.1.1.1 via 192.168.1.1 dev wlan0 src 192.168.1.42 uid 1000
→ clipboard: 192.168.1.42
```

Needs `ip` (iproute2) and `wl-copy`; `notify-send` is optional. The address lookup is tested
headless; the clipboard and notification need a Wayland desktop to verify.
