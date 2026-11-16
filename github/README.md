# github

Your GitHub in zunder: repos, your pull requests, review requests, issues and notifications.

| Type | Shows |
|------|-------|
| `gh` | a menu with counts (pull requests, review requests, issues, notifications), then your repos |
| `gh <words>` | repos matching the words, then your open PRs and issues that match |
| `gh pr [words]` | your open pull requests (`prs`, `pulls`, `mr` work too) |
| `gh review [words]` | open PRs waiting on your review |
| `gh issues [words]` | open issues assigned to you or opened by you |
| `gh notif [words]` | unread notifications (`inbox` works too) |
| `gh repo [words]` | only repos |

Every row has its own octicon: open PR, draft PR, review, issue, mention, release, private
repo, fork. The hint shows CI ( passing,  failing,  running), the review state, the comment
count and how long ago it changed. The preview pane shows the branch, `+/-` lines, labels and
the description.

Enter opens it on github.com. Ctrl+K:

- PRs: copy URL, copy `owner/repo#12`, open changed files, open checks, copy the branch name,
  copy `gh pr checkout 12 -R owner/repo`, open the repo
- issues: copy URL, copy `owner/repo#12`, open the repo
- repos: copy URL or SSH clone URL, open issues / pull requests / actions, new issue, and
  "Filter my PRs and issues here"

Settings:

- `token`: a GitHub token. Optional; without it the plugin uses the `gh` CLI (`gh auth login`).
  Notifications need a classic token with `notifications` (fine-grained tokens can't read
  them); everything else works with either kind.
- `limit`: how many repos to load, default 100.

Repos are cached in `~/.cache/zunder/github-repos.json` for 10 minutes, PRs, issues and
notifications in `github-work.json` for 90 seconds (one GraphQL call plus one REST call).
After that the old data is shown and refreshed in the background, so typing never waits on
the network. The menu never waits either: its counts show `…` until the first fetch is done.

```json
{"title": "Pull requests", "subtitle": "your open PRs", "hint": "1", "glyph": "", "action": {"fill": "gh pr "}}
{"title": "Add zunder to runners and launchers", "subtitle": "hyprland-community/awesome-hyprland #235", "hint": " needs review · 3w", "glyph": "", "action": {"open": "https://github.com/hyprland-community/awesome-hyprland/pull/235"}}
{"title": "Sign Windows builds (Defender flags the unsigned 0.5.0 exe)", "subtitle": "elyesghazel/zunder #27", "hint": "opened by you · 15h", "glyph": "", "action": {"open": "https://github.com/elyesghazel/zunder/issues/27"}}
```

Tested headless against the real API through `gh` and with a bad token (error shown as a row):
~600 ms to 2 s on the first call, ~75 ms from cache. Not tested: notifications with entries
(the test account had none unread), the token path with a real token, and opening links, which
needs a desktop.
