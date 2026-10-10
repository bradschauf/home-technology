#!/usr/bin/env bash
# Flip apex A (and www A where it exists) to schauf-server for completed domains.
# www that is a CNAME to apex is left alone (it follows). Logs to cutover-flip.log.
export PATH=/usr/local/bin:/usr/bin:/bin
cd "$(dirname "$0")"
NEWIP=44.231.156.226
LOG=cutover-flip.log; : > "$LOG"

# domain : www-is-A? (yes = also flip www A record)
flip() {
  local d="$1" wwwA="$2"
  local zid; zid=$(cat "zone-ids/$d.id")
  local changes="{ \"Action\": \"UPSERT\", \"ResourceRecordSet\": { \"Name\": \"$d.\", \"Type\": \"A\", \"TTL\": 300, \"ResourceRecords\": [{\"Value\": \"$NEWIP\"}] } }"
  if [ "$wwwA" = "yes" ]; then
    changes="$changes, { \"Action\": \"UPSERT\", \"ResourceRecordSet\": { \"Name\": \"www.$d.\", \"Type\": \"A\", \"TTL\": 300, \"ResourceRecords\": [{\"Value\": \"$NEWIP\"}] } }"
  fi
  local batch="/tmp/flip-$d.json"
  echo "{ \"Comment\": \"cutover $d\", \"Changes\": [ $changes ] }" > "$batch"
  local st
  st=$(aws route53 change-resource-record-sets --hosted-zone-id "$zid" --change-batch "file://$batch" --query 'ChangeInfo.Status' --output text 2>&1)
  echo "$d -> $st (wwwA=$wwwA)" | tee -a "$LOG"
  rm -f "$batch"
}

flip 2ndaob.com no
flip bradschauf.com yes
flip flightoftheshroud.com no
flip gladdenwatch.com no
flip indecisionranch.com no
flip lindaschauf.com no
flip nathanschauf.com no
flip schauf.org no
flip schaufs.com yes
flip shelbieschauf.com no
flip shelbiestevenson.com no
flip theschaufs.com yes
flip trialoftheshroud.com no
flip wekenb.org no
echo "ALL FLIPS SUBMITTED" | tee -a "$LOG"
