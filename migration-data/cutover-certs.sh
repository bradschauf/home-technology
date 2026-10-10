#!/usr/bin/env bash
# Issue Let's Encrypt certs (certbot --nginx, HTTP-01) for cut-over domains.
# Runs ON schauf-server. Logs per domain. Each domain + its www.
set +e
LOG=/tmp/cutover-certs.log; : > "$LOG"
EMAIL=brad@theschaufs.com

issue() {
  local d="$1"
  echo "=== $d ===" >> "$LOG"
  sudo certbot --nginx -d "$d" -d "www.$d" \
    --non-interactive --agree-tos -m "$EMAIL" --no-eff-email --redirect \
    >> "$LOG" 2>&1
  if [ $? -eq 0 ]; then echo "$d: OK" >> "$LOG"; else echo "$d: FAILED" >> "$LOG"; fi
}

for d in 2ndaob.com bradschauf.com flightoftheshroud.com gladdenwatch.com \
         indecisionranch.com lindaschauf.com nathanschauf.com schauf.org \
         schaufs.com shelbieschauf.com shelbiestevenson.com theschaufs.com \
         trialoftheshroud.com wekenb.org; do
  issue "$d"
done
echo "ALL CERTS DONE" >> "$LOG"
grep -E ": OK|: FAILED" "$LOG"
