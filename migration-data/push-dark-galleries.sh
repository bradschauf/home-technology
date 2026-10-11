#!/usr/bin/env bash
# Push the dark galleries (staging-dark/) to schauf-server bradschauf.com docroot,
# preserving dir names so URLs match (https://bradschauf.com/<dir>/).
# Sync to /tmp staging on server, then sudo-move into docroot (no --delete).
export PATH=/usr/local/bin:/usr/bin:/bin
cd "$(dirname "$0")"
LOG=push-dark-galleries.log; : > "$LOG"
KEY="$HOME/.ssh/schauf-server.pem"
HOST="ubuntu@44.231.156.226"
DOCROOT="/var/www/bradschauf.com/public"

echo "[$(date +%H:%M:%S)] START push" >> "$LOG"
# 1) sync to a temp dir on the server (ubuntu-writable)
rsync -az --timeout=600 --partial -e "ssh -i $KEY -o ConnectTimeout=25" \
  staging-dark/ "$HOST:/tmp/dark-galleries/" >> "$LOG" 2>&1
echo "[$(date +%H:%M:%S)] uploaded to /tmp, moving into docroot" >> "$LOG"
# 2) move into docroot without deleting existing content, fix ownership
ssh -i "$KEY" -o ConnectTimeout=25 "$HOST" \
  "sudo rsync -a /tmp/dark-galleries/ $DOCROOT/ && sudo chown -R www-data:www-data $DOCROOT && rm -rf /tmp/dark-galleries" >> "$LOG" 2>&1
echo "[$(date +%H:%M:%S)] rsync-move exit=$?" >> "$LOG"
echo "ALL DONE" >> "$LOG"
