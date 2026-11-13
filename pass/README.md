# pass

`pass <words>` searches your [pass](https://www.passwordstore.org/) or
[gopass](https://www.gopass.pw/) entries; every word has to appear in the entry path.

- Enter copies the password (`pass -c` / `gopass show -c`, which clear the clipboard again).
- Ctrl+K: copy the username (the first `user:`, `username:`, `login:` or `email:` line of the
  entry, else the entry's last path component), or edit the entry in your terminal.

Setting `backend`: `pass` or `gopass`. Default: gopass if it's installed, else pass. pass reads
`$PASSWORD_STORE_DIR` (default `~/.password-store`).

```json
{"title": "web/github.com", "subtitle": "Enter copies the password", "hint": "pass", "action": {"run": "pass -c web/github.com"}}
```

Needs `pass` or `gopass`, and `wl-copy` for the username. Tested with a fake store and a fake
`pass` (`--user` parsing, quoting of names with `'`), ~50 ms per call. Decrypting needs your GPG
key and a pinentry, so the copy actions need a real desktop to verify.
