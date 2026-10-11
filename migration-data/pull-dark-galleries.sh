#!/usr/bin/env bash
# Pull the "dark" (unlinked) galleries from old Bluehost bradschauf/ in a SINGLE
# rsync connection (avoids tripping Bluehost cPHulk, which blocks on many rapid SSH
# connections). Transfers only the listed gallery dirs; excludes already-migrated
# content (blog/videos/whiterabbit/speedmon) and root-level loose files.
# Logs to pull-dark-galleries.log. Safe to re-run (rsync incremental, resumes).
export PATH=/usr/local/bin:/usr/bin:/bin
cd "$(dirname "$0")"
LOG=pull-dark-galleries.log; : > "$LOG"
DEST="staging-dark"
mkdir -p "$DEST"

# One connection: sync bradschauf/ but include ONLY the gallery dirs (recursively),
# exclude everything else. Trailing-slash include rules + final exclude.
echo "[$(date +%H:%M:%S)] START (single connection)" >> "$LOG"
rsync -az --timeout=900 --partial \
  -e "ssh -i $HOME/.ssh/schauf.priv -o ConnectTimeout=25" \
  --include='HCR26/***' \
  --include='packages/***' \
  --include='web/***' \
  --include='euro-monkey/***' \
  --include='oldsite/***' \
  --include='son-in-law-interview/***' \
  --include='edgestone-nw/***' \
  --include='911/***' \
  --include='resume/***' \
  --include='2026alaska/***' \
  --include='parenting/***' \
  --include='voice/***' \
  --include='Lizzie/***' \
  --include='Ringtones/***' \
  --include='auntkaren/***' \
  --include='gigi/***' \
  --include='images/***' \
  --include='shane/***' \
  --include='airtug/***' \
  --include='porsche/***' \
  --include='work/***' \
  --include='gfhoa/***' \
  --include='TFD25/***' \
  --include='TFD26/***' \
  --include='Kayla/***' \
  --exclude='*' \
  "theschau@50.87.221.44:public_html/bradschauf/" "$DEST/" >> "$LOG" 2>&1
rc=$?
echo "[$(date +%H:%M:%S)] rsync exit=$rc total: $(du -sh $DEST 2>/dev/null | cut -f1), $(find $DEST -type f | wc -l) files" >> "$LOG"
echo "ALL DONE" >> "$LOG"
