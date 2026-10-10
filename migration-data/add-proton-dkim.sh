#!/usr/bin/env bash
# Add ProtonMail DKIM CNAMEs (3 selectors per domain) to each Route 53 zone.
# Values recovered from Bluehost's old NS (each domain has a unique proton.ch hash).
# Missed in Phase 1 (DKIM selectors weren't queried). No associative arrays (bash 3.2 safe).
export PATH=/usr/local/bin:/usr/bin:/bin
cd "$(dirname "$0")"

# domain|zoneid|hash
for row in \
  "theschaufs.com|Z00507342HW80IPFGY535|db2krxc2aarbzpjkbfvf3gri4lfkk7za5fjkjbazr3azpdgx5rfnq" \
  "schaufs.com|Z01410112DNNV8KRZHISN|d4blywx5ddenqmtugzscf3n4hciol74xt7h5c5pbfadwni5tfjbia" \
  "bradschauf.com|Z03549351NX3U9KFA7HHS|db3dk5udsjdg6rx6wgcvwlngka6u6iadud3ocpxclefezy3uyiqsa" \
  "schaufwerks.com|Z014246725GRRWDVD6HUF|dmbhfqvjufwnrnkrehr7yalp453vgyow6uy63oqdmsq4lacnr5z6q" ; do
  d=$(echo "$row" | cut -d'|' -f1)
  z=$(echo "$row" | cut -d'|' -f2)
  h=$(echo "$row" | cut -d'|' -f3)
  changes=""
  for s in protonmail protonmail2 protonmail3; do
    [ -n "$changes" ] && changes="$changes,"
    changes="$changes { \"Action\": \"UPSERT\", \"ResourceRecordSet\": { \"Name\": \"$s._domainkey.$d.\", \"Type\": \"CNAME\", \"TTL\": 300, \"ResourceRecords\": [{\"Value\": \"$s.domainkey.$h.domains.proton.ch.\"}] } }"
  done
  echo "{ \"Comment\": \"ProtonMail DKIM for $d\", \"Changes\": [ $changes ] }" > "/tmp/dkim-$d.json"
  st=$(aws route53 change-resource-record-sets --hosted-zone-id "$z" --change-batch "file:///tmp/dkim-$d.json" --query 'ChangeInfo.Status' --output text 2>&1)
  echo "$d -> $st (3 DKIM CNAMEs)"
  rm -f "/tmp/dkim-$d.json"
done
