#!/usr/bin/env bash
# Phase 1 helper: convert captured Bluehost DNS records into Route 53
# change-batch JSON per domain. Writes local JSON only; does NOT touch AWS.
#
# Final policy (confirmed 2026-10-03):
#  - apex A + www A kept at 50.87.221.44 (cutover changes them later).
#  - KEEP ProtonMail MX+SPF+protonmail-verification TXT: theschaufs.com,
#    schaufs.com, bradschauf.com, schaufwerks.com.
#  - DROP all other MX (cPanel mail + Google Workspace schauf.org retired).
#  - DROP all ghs.google.com CNAMEs and google-site-verification TXT.
#  - DROP cPanel service hostnames: cpanel, webmail, ftp, mail, autodiscover, autoconfig.
#  - KEEP _dmarc TXT where present.
#  - NEVER copy SOA/NS (Route 53 creates its own).
set -euo pipefail
cd "$(dirname "$0")"
RECORDS_DIR=records
OUT_DIR=r53-batches
mkdir -p "$OUT_DIR"

# Only these domains keep mail (all ProtonMail).
KEEP_MAIL="theschaufs.com schaufs.com bradschauf.com schaufwerks.com"

for f in "$RECORDS_DIR"/*.txt; do
  domain=$(basename "$f" .txt)
  keep_mail=false
  if echo " $KEEP_MAIL " | grep -q " $domain "; then keep_mail=true; fi

  python3 - "$f" "$domain" "$keep_mail" > "$OUT_DIR/$domain.json" <<'PY'
import sys, json, collections
path, domain, keep_mail = sys.argv[1], sys.argv[2], (sys.argv[3] == "true")

# cPanel service hostnames to drop (relative labels, with domain appended).
DROP_LABELS = {"cpanel", "webmail", "ftp", "mail", "autodiscover", "autoconfig"}

groups = collections.OrderedDict()   # (name,type) -> list(rdata)
ttls = {}                            # (name,type) -> ttl

def label_of(name, domain):
    n = name.rstrip('.')
    if n == domain:
        return "@"
    if n.endswith("." + domain):
        return n[:-(len(domain)+1)]
    return n

with open(path) as fh:
    for line in fh:
        line = line.rstrip("\n")
        if not line or line.startswith(";"):
            continue
        toks = line.split()
        if len(toks) < 5:
            continue
        name, ttl, cls, rtype = toks[0], toks[1], toks[2], toks[3]
        rdata = " ".join(toks[4:])
        if cls != "IN":
            continue
        if rtype in ("SOA", "NS"):
            continue
        lbl = label_of(name, domain)
        # Drop cPanel service hostnames entirely.
        if lbl in DROP_LABELS:
            continue
        # Drop MX unless this domain keeps (ProtonMail) mail.
        if rtype == "MX" and not keep_mail:
            continue
        # Drop ghs.google.com CNAMEs.
        if rtype == "CNAME" and "ghs.google.com" in rdata:
            continue
        # Drop google-site-verification TXT.
        if rtype == "TXT" and "google-site-verification" in rdata:
            continue
        # Drop old Google/Bluehost-IP SPF on domains that no longer send
        # (keep SPF only for ProtonMail domains).
        if rtype == "TXT" and rdata.startswith('"v=spf1') and not keep_mail:
            continue
        key = (lbl, rtype)
        groups.setdefault(key, [])
        if rdata not in groups[key]:
            groups[key].append(rdata)
        try:
            t = int(ttl)
        except ValueError:
            t = 300
        ttls[key] = min(ttls.get(key, t), t)

# Ensure www exists as an A record to the server for every domain
# (fixes the broken ghs.google.com www we just removed).
if ("www", "CNAME") not in groups and ("www", "A") not in groups:
    groups[("www", "A")] = ["50.87.221.44"]
    ttls[("www", "A")] = 300

changes = []
for (lbl, rtype), rdatas in groups.items():
    fqdn = domain + "." if lbl == "@" else f"{lbl}.{domain}."
    changes.append({
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": fqdn,
            "Type": rtype,
            "TTL": ttls[(lbl, rtype)],
            "ResourceRecords": [{"Value": rd} for rd in rdatas],
        },
    })

print(json.dumps({"Comment": f"Phase1 import {domain}", "Changes": changes}, indent=2))
PY
  n=$(python3 -c "import json;print(len(json.load(open('$OUT_DIR/$domain.json'))['Changes']))")
  echo "$domain -> $n record sets  (keep_mail=$keep_mail)"
done
