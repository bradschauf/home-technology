#!/usr/bin/env bash
# Pull WordPress site files from Bluehost to local staging, one at a time,
# spaced to avoid cPHulk. Logs progress to pull-wp-files.log.
cd "$(dirname "$0")"
LOG=pull-wp-files.log
: > "$LOG"
SSH="ssh -i $HOME/.ssh/schauf.priv -o ConnectTimeout=25"
EXCL="--exclude=.cpanel* --exclude=.htpasswds --exclude=.well-known"

pull() {
  local name="$1" path="$2"
  mkdir -p "staging-wp/$name"
  echo "[$(date +%H:%M:%S)] START $name ($path)" >> "$LOG"
  rsync -az --timeout=300 -e "$SSH" $EXCL \
    "theschau@theschaufs.com:$path/" "staging-wp/$name/" >> "$LOG" 2>&1
  echo "[$(date +%H:%M:%S)] DONE  $name -> $(du -sh staging-wp/$name 2>/dev/null | cut -f1), $(find staging-wp/$name -type f | wc -l) files" >> "$LOG"
  sleep 10
}

pull indecisionranch   public_html/indecisionranch
pull nathanschauf      public_html/nathanschauf/blog
pull shelbieschauf     public_html/shelbieschauf/blog
pull shelbiestevenson  public_html/shelbiestevenson/blog
pull bradschauf-blog   public_html/bradschauf/blog
echo "[$(date +%H:%M:%S)] ALL DONE" >> "$LOG"
