# quicklinks

`q <key> <query>` opens a search on a site. `q` alone lists the keys; Enter on one fills in
`q <key> ` so you can type the query.

Built in: `yt` YouTube, `wiki` Wikipedia, `aur` AUR, `crates` crates.io, `gh` GitHub,
`maps` OpenStreetMap.

Setting `links`: more links as `key=url` separated by spaces, `{}` is replaced by the query.
A key that already exists is overridden.

```
links = "mdn=https://developer.mozilla.org/search?q={} yt=https://invidious.example/search?q={}"
```

```json
{"title": "YouTube: lofi beats", "hint": "yt", "action": {"open": "https://www.youtube.com/results?search_query=lofi%20beats"}}
{"title": "developer.mozilla.org: flex box", "hint": "mdn", "action": {"open": "https://developer.mozilla.org/search?q=flex%20box"}}
```

No dependencies besides Python 3. Tested headless with `jq`; opening links needs a desktop.
