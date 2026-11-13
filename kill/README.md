# kill

Search your processes by name, sorted by CPU. Enter kills one. When a name matches more than one
process (a browser, Spotify), the first row kills all of them.

```
kill firefox
```

```json
{"title": "kill all firefox", "subtitle": "12 processes · firefox, Isolated Web Co", "hint": "2140 MB", "action": {"run": "kill 4242 4250 …"}}
{"title": "firefox", "subtitle": "pid 4242", "hint": "6% · 712 MB", "action": {"run": "kill 4242"}}
```

Needs `ps` and Python 3. Tested headless (queries + `jq`); nothing here needs a desktop.
