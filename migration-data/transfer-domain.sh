#!/usr/bin/env bash
# Transfer ONE domain's registration into Route 53 Domains, using the
# Route 53 hosted-zone nameservers we built in Phase 1.
#
# Prereqs (manual, at Bluehost portal, per domain):
#   1. Unlock the domain (remove clientTransferProhibited)
#   2. Get the EPP/auth code
#   3. Ensure WHOIS privacy isn't blocking transfer
#
# Secrets are read from gitignored files; nothing secret is printed.
#
# Usage: ./transfer-domain.sh <domain>
#   Expects:
#     migration-data/contact.json           (registrant contact; see template)
#     migration-data/secrets/<domain>.auth  (one line: the EPP/auth code)
#     migration-data/ns-sets/<domain>.ns     (R53 nameservers, from Phase 1)
set -euo pipefail
cd "$(dirname "$0")"
REGION=us-east-1   # route53domains is only in us-east-1
domain="${1:?usage: transfer-domain.sh <domain>}"

contact=contact.json
authfile="secrets/$domain.auth"
nsfile="ns-sets/$domain.ns"

for f in "$contact" "$authfile" "$nsfile"; do
  [ -f "$f" ] || { echo "MISSING required file: $f" >&2; exit 1; }
done

echo "== [1/4] Pre-flight transferability check: $domain =="
transferable=$(aws route53domains check-domain-transferability \
  --region "$REGION" --domain-name "$domain" \
  --query 'Transferability.Transferable' --output text 2>&1 || true)
echo "   Transferable: $transferable"
if [ "$transferable" != "TRANSFERABLE" ]; then
  echo "   -> NOT transferable yet. Unlock the domain at Bluehost and retry." >&2
  aws route53domains check-domain-transferability --region "$REGION" \
    --domain-name "$domain" --query 'Transferability' --output json >&2 || true
  exit 2
fi

echo "== [2/4] Building nameserver + contact args =="
# Build Nameservers list from the .ns file (one host per line).
ns_json=$(python3 - "$nsfile" <<'PY'
import sys, json
hosts=[l.strip() for l in open(sys.argv[1]) if l.strip()]
print(json.dumps([{"Name": h} for h in hosts]))
PY
)
# Contact blocks reused for registrant/admin/tech.
contact_json=$(python3 - "$contact" <<'PY'
import sys, json
c=json.load(open(sys.argv[1]))
c.pop("_comment", None)
print(json.dumps(c))
PY
)
auth=$(tr -d '\r\n' < "$authfile")

echo "   Nameservers: $(python3 -c "import json,sys;print(', '.join(n['Name'] for n in json.loads(sys.argv[1])))" "$ns_json")"

echo "== [3/4] Submitting transfer-domain for $domain =="
op=$(aws route53domains transfer-domain \
  --region "$REGION" \
  --domain-name "$domain" \
  --duration-in-years 1 \
  --auth-code "$auth" \
  --nameservers "$ns_json" \
  --admin-contact "$contact_json" \
  --registrant-contact "$contact_json" \
  --tech-contact "$contact_json" \
  --privacy-protect-admin-contact \
  --privacy-protect-registrant-contact \
  --privacy-protect-tech-contact \
  --query 'OperationId' --output text 2>&1)

if ! echo "$op" | grep -qE '^[0-9a-f-]{36}$'; then
  echo "   ERROR submitting transfer: $op" >&2
  exit 3
fi
echo "   Operation ID: $op"
echo "$op" > "secrets/$domain.op"

echo "== [4/4] Initial status =="
aws route53domains get-operation-detail --region "$REGION" \
  --operation-id "$op" --query '{Status:Status,Type:Type,Message:Message}' --output json
echo
echo "Transfer submitted. Watch for AWS/Bluehost approval emails to the registrant"
echo "contact; approve them. Poll later with:"
echo "  aws route53domains get-operation-detail --region $REGION --operation-id $op"
