#!/usr/bin/env bash
# Batch transfer runner. Default = DRY RUN (checks only, submits nothing).
# Pass --submit to actually submit transfers for every READY domain.
#
# A domain is READY when: it has a non-empty secrets/<domain>.auth,
# it is TRANSFERABLE at the registry (unlock propagated), and it has NOT
# already been submitted (no secrets/<domain>.op).
set -euo pipefail
cd "$(dirname "$0")"
REGION=us-east-1
SUBMIT=false
[ "${1:-}" = "--submit" ] && SUBMIT=true

ready=(); skip_empty=(); skip_locked=(); skip_done=()

for authf in secrets/*.auth; do
  domain=$(basename "$authf" .auth)
  # already submitted?
  if [ -f "secrets/$domain.op" ]; then skip_done+=("$domain"); continue; fi
  # auth present?
  if [ ! -s "$authf" ]; then skip_empty+=("$domain"); continue; fi
  # transferable?
  t=$(aws route53domains check-domain-transferability --region "$REGION" \
        --domain-name "$domain" --query 'Transferability.Transferable' --output text 2>/dev/null || echo ERROR)
  if [ "$t" = "TRANSFERABLE" ]; then ready+=("$domain"); else skip_locked+=("$domain ($t)"); fi
done

echo "===== BATCH TRANSFER PLAN ($([ "$SUBMIT" = true ] && echo SUBMIT || echo DRY-RUN)) ====="
echo "READY to submit (${#ready[@]}): ${ready[*]:-none}"
echo "Already submitted (${#skip_done[@]}): ${skip_done[*]:-none}"
echo "Empty auth, skipped (${#skip_empty[@]}): ${skip_empty[*]:-none}"
echo "Not transferable yet (${#skip_locked[@]}): ${skip_locked[*]:-none}"
echo

if [ "$SUBMIT" != true ]; then
  echo "Dry run only. Re-run with --submit to transfer the READY domains."
  exit 0
fi

echo "Submitting ${#ready[@]} transfer(s)..."
for domain in "${ready[@]}"; do
  echo "--- $domain ---"
  ./transfer-domain.sh "$domain" >/dev/null 2>&1 && \
    echo "   submitted (op $(cat secrets/$domain.op 2>/dev/null))" || \
    echo "   FAILED — run ./transfer-domain.sh $domain to see the error"
done
echo
echo "Done. Poll with ./check-transfers.sh"
