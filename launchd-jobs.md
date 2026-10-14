# LaunchD Jobs (Brad's Mac)

Scheduled jobs run via `launchd` on Brad's Mac. Plists live in
`~/Library/LaunchAgents/com.bradschauf.*.plist`. Migrated from cron (July 2026).

Weekday numbers in `StartCalendarInterval`: 0 = Sunday, 6 = Saturday.

## Jobs

| Label | Script | Schedule | Enabled | Logs |
|---|---|---|---|---|
| `com.bradschauf.check-sites` | `~/check-sites.sh` | every 300s (5 min) | ✅ enabled | `~/logs/check-sites.log` |
| `com.bradschauf.text-kids` | `~/GitHub/text-messages/text-kids.sh` | Sat 08:00 | ✅ enabled | `~/logs/text-kids.err` |
| `com.bradschauf.text-kids-prayer` | `~/GitHub/text-messages/text-kids-prayer.sh` | Sun 08:00 | ✅ enabled | `~/logs/text-kids-prayer.err` |
| `com.bradschauf.text-mom-dad-amy` | `~/GitHub/text-messages/text-mom-dad-amy.sh` | Sat 09:00 | ✅ enabled | `~/logs/text-mom-dad-amy.err` |
All jobs run via `/bin/bash <script>`.

### Removed 2026-10-11
Deleted (jobs + plists + loose scripts) as no longer needed:
- `com.bradschauf.cf-db-backup-pull` (`~/cf-db-backup-pull.sh`) — pulled catholicfunctions
  DB backup S3→iCloud. **Note:** removing this stops the off-site (iCloud) DB backup copy.
- `com.bradschauf.backup-download` (`~/GitHub/catholicfunctions/deploy/vps/download-backup.sh`)
  — downloaded backups from the now-cancelled catholicfunctions Bluehost VPS; obsolete. The
  Mac job + plist are gone; the `download-backup.sh` script still lives in the
  catholicfunctions repo (delete there if wanted).
- `com.bradschauf.check-server-updates` (`~/check-server-updates.sh`) — checked for server
  updates; obsolete.

## What each does

- **check-sites** — website uptime monitoring; alerts via iMessage
  (`~/GitHub/text-messages/send-imessage.sh` → 858-414-1381). Config `~/websites.json`.
- **text-kids** / **text-kids-prayer** / **text-mom-dad-amy** — scheduled family texts
  (motivational / prayer / family) via the `text-messages` repo scripts.

## Managing jobs

```bash
launchctl list | grep bradschauf                                  # list loaded jobs
launchctl start com.bradschauf.<name>                             # run immediately
launchctl bootout gui/$(id -u)/com.bradschauf.<name>              # stop/unload
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.bradschauf.<name>.plist  # load
launchctl enable gui/$(id -u)/com.bradschauf.<name>               # enable if disabled
launchctl print-disabled gui/$(id -u) | grep bradschauf           # check disabled state
```

After editing a plist, reload it: `bootout` then `bootstrap` (above).
