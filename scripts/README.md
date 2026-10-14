# scripts/

Version-controlled home for Brad's personal utility/helper scripts. **This repo is the
one true copy** — don't keep duplicate loose copies in the home dir.

| Script | Purpose | How it's invoked |
|---|---|---|
| `check-sites.sh` | Website uptime monitor; alerts via iMessage on confirmed-down. Has an internet-connectivity preflight (skips silently when offline). | launchd `com.bradschauf.check-sites` every 5 min, pointed at this path. |
| `websites.json` | Config for `check-sites.sh` — the list of URLs to monitor. Must sit beside `check-sites.sh` (script reads it from its own dir). | read by check-sites.sh |
| `theschaufs.sh` | SSH into the NEW server (schauf-server, `ubuntu@44.231.156.226`). | `~/theschaufs.sh` (symlink → here) |
| `schaufserver.sh` | SSH into the NEW server (same as above). | `~/schaufserver.sh` (symlink → here) |
| `old-theschaufs.sh` | SSH into the OLD Bluehost shared box (`theschau@50.87.221.44`, by IP). | `~/old-theschaufs.sh` (symlink → here) |

## Symlinks from home dir
The three SSH helpers are symlinked from `~/` so they can still be run as `./theschaufs.sh`
etc., while the real file lives here under version control:

```bash
ln -sf ~/GitHub/home-technology/scripts/theschaufs.sh    ~/theschaufs.sh
ln -sf ~/GitHub/home-technology/scripts/schaufserver.sh  ~/schaufserver.sh
ln -sf ~/GitHub/home-technology/scripts/old-theschaufs.sh ~/old-theschaufs.sh
```

`check-sites.sh` is NOT symlinked — launchd calls it by its absolute repo path.

## Note
Family text scripts (text-kids, text-kids-prayer, text-mom-dad-amy, send-imessage) live
in their own repo `~/GitHub/text-messages/` and are not duplicated here.
