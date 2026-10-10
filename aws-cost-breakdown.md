# AWS Cost Breakdown — account 566105881027

Snapshot of billable resources as of 2026-10-04, split by project so you can decide
what to keep. Region: us-west-2. Prices are approximate list prices (USD/month);
actual bill varies with usage (CloudFront egress, DNS queries).

---

## 1. Personal migration (schauf-server) — THE STUFF WE BUILT

| # | Resource | Detail | Monthly | Keep? |
|---|---|---|---|---|
| 1 | Lightsail `schauf-server` | small_3_0 (2 GB/2 vCPU/60 GB) | **$12.00** | needed — the web server |
| 2 | Static IP `schauf-server-ip` | attached to running instance | $0.00 | free while attached |
| 3 | S3 `bradschauf-media` | 72 GB (76.96 GB) Standard @ ~$0.023/GB | **~$1.77** | needed — the videos |
| 4 | CloudFront `E2XK5VTX2AB0AM` | egress ~$0.085/GB streamed | **variable** | needed — serves videos |
| 5 | Route 53 zones (personal) | 18 zones @ $0.50 | **$9.00** | see §3 — can trim |
| 6 | Route 53 DNS queries | ~$0.40/million (low traffic) | **~$0.10** | negligible |
| | **Personal subtotal (excl. CloudFront traffic)** | | **~$22.90/mo** | |

**CloudFront traffic estimate** (the only big variable):
- Light family viewing (~20 GB/mo): ~$1.70
- Moderate (~100 GB/mo): ~$8.50
- Realistic personal/family: **a few $/mo**

→ **Personal all-in: ~$25–30/month.**

---

## 2. NOT the personal migration (catholicfunctions / flock project)

These share the same AWS bill but are a different project (hands-off here). Listed
so you know what's driving the total — decisions on these belong to that project.

| Resource | Detail | Monthly |
|---|---|---|
| Lightsail `catholic-functions-xl` | xlarge_3_0 (16 GB / 4 vCPU / 320 GB) | **$84** |
| Lightsail `flock-functions` | medium_3_0 (4 GB / 2 vCPU / 80 GB) | **$24** |
| Static IP `catholic-functions-ip` | attached | $0.00 |
| Static IP `flock-functions-ip` | attached | $0.00 |
| S3 `flock-functions-backups` | 0 objects (empty) | $0.00 |
| Lightsail snapshot `catholic-functions-resize-2026-09-26` | 60 GB instance snapshot | **~$3.00** |
| Route 53 `catholicfunctions.com` + `flockfunctions.com` | 2 zones @ $0.50 | **$1.00** |
| **Other-project subtotal** | | **~$112/mo** |

**Right-sizing / consolidation (scoped in `aws-rightsizing-plan.md` +
`catholicfunctions` repo → `VPS-RETIREMENT-AND-RIGHTSIZING.md`):** `catholic-functions-xl` is a warm
**failover**, not current prod — catholic prod is on the Bluehost VPS. Plan: promote
the xlarge to prod, retire the Bluehost VPS, fold in staging + flock, delete the flock
instance, then right-size down from xlarge based on REAL prod load (not current idle
metrics). End state ≈ one Lightsail instance (likely $44 large) vs $108/mo now — saves
~$64/mo PLUS the whole Bluehost VPS fee. Owned by the catholicfunctions project
(needs its VPS/Lightsail keys). Also resolves stranded staging.catholicfunctions.com.
Leftover `catholic-functions-resize` snapshot (~$3/mo) deletable once settled.

---

## 3. Where the personal cost can be trimmed

**Route 53 zones ($0.50 each) — 18 personal zones = $9/mo.** Some are low-value:
- `trialoftheshroud.com` — only a redirect to flightoftheshroud. Could drop the zone
  and handle the redirect differently, but $0.50 to keep it simple is fine.
- `sadff.com` — being handed off to someone else; its zone is parked. Once handed off,
  this zone goes away (the new owner hosts DNS).
- `lilsproutdoodles.com` — transfer held; still has a zone.
- `wekenb.org` — website excluded; domain kept. Parked zone.
- `theschaufs.com`, `schauf.org` — park-for-now (will become real sites).
- Trimming the few truly-dead ones might save ~$1.50–2/mo. Minor; keep for simplicity
  unless you want to prune.

**Lightsail instance** — $12 is already the right-sized tier (media offloaded to S3,
so RAM not disk is the constraint). No savings without under-provisioning.

**S3 storage class** — the ~14 GB of unlinked legacy galleries (not actively watched)
could move to S3 Standard-IA or Glacier Instant Retrieval to shave a few cents. Not
worth the complexity at this scale (~$1.77 total already).

---

## 4. Bottom line

- **Personal migration cost: ~$25–30/month** (Lightsail $12 + Route 53 $9 + S3 ~$2 +
  CloudFront a few $). Replaces Bluehost shared hosting.
- **Full account bill: ~$137/month today**, of which ~$112 is the catholicfunctions/
  flock project and ~$25 is this personal migration.
- One-time: ~$250–280 of domain transfers (Phase 2), which prepaid a year of
  registration per domain.

**Savings lever:** right-sizing catholicfunctions/flock (see `aws-rightsizing-plan.md`)
cuts ~$72–77/mo → full account bill drops to **~$60–65/mo**. That instance is the
other project's, but the plan is scoped and ready when they want it (it also rehomes
the stranded staging.catholicfunctions.com).
