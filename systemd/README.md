# systemd

`sd <words>` searches user and system services by name, description, scope (`user`, `system`)
or state (`failed`, `active`, `inactive`). Failed units come first, then active ones.

- The preview pane shows state, since when, PID, memory, enabled state and unit file.
- Enter opens `systemctl status` plus the last 30 journal lines in your terminal.
- Ctrl+K: Start, Stop, Restart, Follow logs (`journalctl -f`). System units go through polkit,
  so your polkit agent asks for the password.

```json
{"title": "t3code", "subtitle": "T3 Code", "hint": "user · active", "action": {"term": "systemctl --user status --no-pager t3code.service; journalctl --user -u t3code.service -n 30 --no-pager"}, "preview": "t3code.service (user)\nT3 Code\n\nstate    active (running)\nsince    Thu 2026-11-12 13:07:01 CET\npid      1203\nmemory   312M\nenabled  enabled\nfile     /home/you/.config/systemd/user/t3code.service"}
```

The list is live on every call; preview details for the first 10 results are cached for 5 s in
`$XDG_RUNTIME_DIR`, so typing stays fast. Measured on a server with ~150 units: ~75 ms with
the cache, ~140 ms when a keystroke brings up units not seen yet.

Needs `systemctl` (systemd 246+ for `-o json`). Tested headless on a real systemd 257 machine
with `jq`. Start/stop through a polkit prompt needs a desktop session to verify.
