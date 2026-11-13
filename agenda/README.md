# agenda

`cal <words>` shows your next events from one or more ICS calendar URLs, soonest first.

- Enter opens the event's video call link (Meet, Zoom, Teams, Webex, Whereby, Jitsi, found in the
  URL, location or description); without one it copies the title and time.
- The preview pane shows the description. Ctrl+K copies the event.

Settings:

- `url`: one or more ICS URLs separated by spaces (`webcal://` works). For Google Calendar use
  "Secret address in iCal format" from the calendar's settings.
- `days`: how many days ahead, default 14.

Calendars are cached in `~/.cache/zunder/agenda/` for 15 minutes; after that the old copy is
shown and refreshed in the background, so typing never waits on the network.

```json
{"title": "Standup", "subtitle": "Wed 18 Nov 09:15–09:30", "hint": "in 4 d", "action": {"open": "https://meet.google.com/abc-defg-hij"}}
{"title": "Trip to Ticino", "subtitle": "Sun 15 Nov · 2 days", "hint": "in 1 d", "action": {"copy": "Trip to Ticino, Sun 15 Nov · 2 days"}}
```

Recurrence: `FREQ=DAILY/WEEKLY/MONTHLY/YEARLY` with `INTERVAL`, `COUNT`, `UNTIL`, `BYDAY`
(including `2MO`, `-1FR` for monthly), `BYMONTHDAY`, plus `EXDATE`, moved occurrences
(`RECURRENCE-ID`) and cancelled events. Rarer rules (`BYSETPOS`, `BYWEEKNO`, hourly) show only
the first occurrence. Windows-style TZIDs fall back to your local time zone.

Only Python 3.9+ stdlib. Tested headless with a hand-written ICS covering each rule above, a real
Google holiday calendar, an unreachable URL and the background refresh, ~80 ms from cache.
Opening call links needs a desktop.
