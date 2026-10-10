#!/usr/bin/env bash
# Push staged WordPress sites to schauf-server. Logs to push-wp-files.log.
# Layout per site:
#   indecisionranch: WP at docroot
#   nathanschauf/shelbieschauf/shelbiestevenson: static root homepage + WP under /blog
#   bradschauf: ONLY the /blog WP (homepage comes from its GitHub repo later;
#               /videos media goes to S3 — not pushed here)
cd "$(dirname "$0")"
LOG=push-wp-files.log
: > "$LOG"
SSHKEY="$HOME/.ssh/schauf-server.pem"
HOST=ubuntu@44.231.156.226
SSH="ssh -i $SSHKEY -o ConnectTimeout=25"

push() {
  local src="$1" dest="$2"
  [ -d "staging-wp/$src" ] || { echo "[skip] no staging-wp/$src" >> "$LOG"; return; }
  echo "[$(date +%H:%M:%S)] START $src -> $dest" >> "$LOG"
  $SSH "$HOST" "sudo mkdir -p $dest && sudo chown -R ubuntu:www-data $dest" >> "$LOG" 2>&1
  rsync -a --timeout=300 -e "$SSH" "staging-wp/$src/" "$HOST:$dest/" >> "$LOG" 2>&1
  echo "[$(date +%H:%M:%S)] DONE  $src -> $dest ($(find staging-wp/$src -type f | wc -l) files)" >> "$LOG"
}

# indecisionranch — WP at docroot
push indecisionranch        /var/www/indecisionranch.com/public

# /blog sites — root homepage first, then WP under /blog
push nathanschauf-root      /var/www/nathanschauf.com/public
push nathanschauf           /var/www/nathanschauf.com/public/blog
push shelbieschauf-root     /var/www/shelbieschauf.com/public
push shelbieschauf          /var/www/shelbieschauf.com/public/blog
push shelbiestevenson-root  /var/www/shelbiestevenson.com/public
push shelbiestevenson       /var/www/shelbiestevenson.com/public/blog

# bradschauf — only the blog (homepage from repo later; media to S3)
push bradschauf-blog        /var/www/bradschauf.com/public/blog

$SSH "$HOST" "sudo chown -R www-data:www-data /var/www" >> "$LOG" 2>&1
echo "[$(date +%H:%M:%S)] ALL DONE" >> "$LOG"
