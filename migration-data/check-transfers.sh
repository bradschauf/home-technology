#!/usr/bin/env bash
# Poll status of all submitted domain transfers (reads secrets/<domain>.op files).
set -euo pipefail
cd "$(dirname "$0")"
REGION=us-east-1
shopt -s nullglob
found=0
for opf in secrets/*.op; do
  found=1
  domain=$(basename "$opf" .op)
  op=$(tr -d '\r\n' < "$opf")
  st=$(aws route53domains get-operation-detail --region "$REGION" --operation-id "$op" \
        --query '{Status:Status,Type:Type,Message:Message}' --output json 2>&1)
  printf '%-24s %s\n' "$domain" "$(echo "$st" | python3 -c 'import json,sys;d=json.load(sys.stdin);print(f"{d.get(\"Status\")}  {d.get(\"Message\") or \"\"}")' 2>/dev/null || echo "$st")"
done
[ "$found" = "1" ] || echo "No submitted transfers yet (no secrets/*.op files)."