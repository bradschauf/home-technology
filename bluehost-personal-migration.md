# Bluehost → AWS Personal Migration

## ▶ RESUME HERE (last updated 2026-10-15)

**Status: migration functionally COMPLETE. All personal sites — including
schaufwerks.com — now live on schauf-server (AWS Lightsail, 44.231.156.226) over
HTTPS; all 18 personal domain registrations now at AWS (Route 53 Domains).
NOTHING personal remains on Bluehost. Bluehost shared hosting account cancelled and
prorated refund received. Migration fully wrapped.**

### Key facts for a fresh session
- **New server:** schauf-server, Lightsail, `44.231.156.226`, Ubuntu 22.04, NGINX +
  PHP 8.3 + MariaDB. SSH: `~/theschaufs.sh` or `~/schaufserver.sh` (ubuntu@…,
  key `~/.ssh/schauf-server.pem`). Docroots `/var/www/<domain>/public`.
- **Old Bluehost box (still up, being decommissioned):** `~/old-theschaufs.sh`
  (theschau@50.87.221.44, key `~/.ssh/schauf.priv`). cPHulk blocks rapid SSH — use
  ONE connection, not many.
- **Mac mini** (`brad@schaufserver.local`, passwordless via schauf.priv): runs speedmon
  manually; already repointed to new server.
- DNS = Route 53 (acct 566105881027). bradschauf media = S3 `bradschauf-media` +
  CloudFront `d1xmnyfjt1ssl3.cloudfront.net`. Router DNS = Cloudflare 1.1.1.1/1.0.0.1.

### What's DONE
- All 16 sites cut over + HTTPS (certbot --nginx). 18 registrations transferred to AWS.
- WordPress (6), gladdenwatch PHP+DB, static sites, park pages, redirects — all live.
- Mail fixed on 4 ProtonMail domains (MX+SPF+DKIM+protonmail-verification+DMARC);
  Google verification TXT restored (bradschauf, jimnewmann).
- "Dark" unlinked galleries (~13 GB: Kayla, TFD25/26, gfhoa, etc.) + whiterabbit (518M,
  267 screenshots) migrated to bradschauf.com docroot; NGINX `autoindex on` enabled for
  those dirs (match old Apache listing). speedmon page + CSV uploader (mac mini) live.
- All deploy scripts (bradschauf, lilsproutdoodles, jimnewmann, flightoftheshroud,
  gladdenwatch, speedmon, white-rabbit) repointed to schauf-server + tested.
- Local staging dirs deleted (~90 GB reclaimed). gladdenwatch Google key rotation:
  Brad opted out (low risk).

### Pre-decommission audit (2026-10-15) — before Bluehost auto-renew lapses
Brad disabled auto-renew on everything at Bluehost. Did a full read-only diff of the old
box (`50.87.221.44`) vs schauf-server + S3. Findings + actions (see §5.7 for detail):
- **Closed 2 content gaps** the original rsync silently skipped:
  - `bradschauf/Kayla/Kayla-Marie-Wilson-2020.mp4` (4.7 GB memorial video) — restored to
    docroot + S3 `_recovered-originals/`. Verified streaming over HTTPS.
  - 9 gigi TIFF originals (`Great_Grandma*.tiff`, `photo2.TIF`) — restored (JPG
    conversions already existed, so site was never broken; originals now preserved).
- **wekenb.org (`wekenborg/`, 117 MB WP site, previously EXCLUDED)** — pulled a safety
  copy to S3 `_recovered-originals/wekenborg-wekenb.org/` (5398 objects) + local. NOT
  rehosted (still intentionally dropped) — just preserved in case.
- **6 WordPress/PHP DB dumps** (`dbdumps_migration/`, Oct 3 snapshots) backed up to S3
  `bradschauf-media/_db-backups-bluehost-20261003/` (weren't stored off Bluehost before).
- **72 GB `videos/` archive** re-verified in S3 (98 objects, exact byte match).
- **Removed the Bluehost crontab** (`crontab -r`) — the lone Laravel `schedule:run` for
  catholicfunctions_app. catholicfunctions runs on AWS now; cron backed up to
  `migration-data/staging-gap-recovery/crontab-backup-20261015.txt`.
- **Mail: intentionally NOT backed up** (Brad's call — ProtonMail is the real mail; cPanel
  boxes unused).
- All other sites: equal/more files on server (WP regenerates caches); only deltas are
  Apache `.htaccess`, stale ACME tokens, `.bak` files — all junk. **Everything needed is
  on AWS; Bluehost can lapse safely.**

### What's LEFT (priority order)
1. **schaufwerks.com** — ✅ RENDERING ON AWS over HTTPS (2026-10-15). The old Weebly
   store on Bluehost broke after the registrar transfer (Bluehost dropped the SSL cert +
   served a Weebly "page cannot be displayed" error). Recovered a static render of the
   storefront on schauf-server (see §5.4b). A record flipped to `44.231.156.226`,
   Let's Encrypt cert issued for apex + www (valid → 2027-01-13), HTTP→HTTPS 301.
   Pages live: Home, Shop, About, Contact — with the original Weebly theme CSS +
   product photos. NOT functional: cart/checkout + individual product pages (Weebly
   `w_api/Handler.php` dynamic commerce, not recoverable as static). **Follow-up:** real
   e-commerce rebuild WITH wife (WooCommerce rec.) when she's ready — the current site is
   a content-preserving render, not a working store.
2. **catholicfunctions.com + flockfunctions.com** — ✅ DONE (transferred to AWS + WHOIS set
   to SchaufWerks, LLC 2026-10-11, registrant+admin+tech).
3. **Cancel Bluehost HOSTING account** — ✅ DONE. Account cancelled, prorated refund
   received. (4 throwaway domains left to expire Feb/Apr 2027; sadff.com stays on
   Squarespace, hand off later.)
4. Backlog: fold dark galleries into bradschauf.com repo; build out theschaufs.com +
   schauf.org (park pages now); Search Console → Domain properties.

### SEPARATE project (not this migration)
catholicfunctions VPS retirement + Lightsail right-sizing →
`~/GitHub/catholicfunctions/VPS-RETIREMENT-AND-RIGHTSIZING.md`.

---
### (historical cutover detail — 2026-10-08)
**CUTOVER:** 17/18 transfers completed → nameservers auto-flipped to Route 53. Bluehost
dropped jimnewmann.com post-transfer (went down), triggering the cutover. Flipped A
records 50.87.221.44 → 44.231.156.226 and issued Let's Encrypt certs for 15 domains.
Scripts: `migration-data/cutover-flip.sh` + `cutover-certs.sh`.

**⚠️ 4 DOMAINS DISCOVERED via Bluehost domain-list export (2026-10-08) — were MISSED
by the original cPanel-based inventory because they have NO website (parked at
Bluehost IP 66.81.203.198, HTTP 000). Still registered at Bluehost, block "fully off
Bluehost" until transferred or dropped:**
- flightoftheshroud.online — `.online` alt of flightoftheshroud.com
- flightoftheshroudofchrist.com — long-form alt of flightoftheshroud
- flightoftheshroudofchrist.online — long-form alt
- gladdenwatch.online — `.online` alt of gladdenwatch.com
All expire Feb/Apr 2027, auto-renew OFF, lock OFF, no privacy. (Bluehost domain
account # 53176628.)
**DECISION (Brad 2026-10-08): LET THEM EXPIRE.** Not migrated, not transferred, not
redirected — throwaway defensive registrations with no sites. Auto-renew is already
OFF so they lapse on their own (Feb/Apr 2027). Ignore Bluehost renewal notices.
NOTE: this keeps the Bluehost *domain-registrar* account open until ~Apr 2027 (harmless,
separate from the hosting account we're decommissioning). Not a gate on anything.

**STILL ON BLUEHOST (not cut over):**
- **schaufwerks.com** — ✅ RESOLVED 2026-10-15. Was live Weebly commerce; Bluehost
  dropped it post-transfer (exactly the predicted risk — store broke). Recovered a
  static render on schauf-server (A flipped to 44.231.156.226, HTTPS live). See §5.4b.
  Still TODO: real store rebuild with wife (WooCommerce rec.).
- **sadff.com** — on Squarespace, A unchanged (points at Squarespace), handing off later.
- **lilsproutdoodles.com** — ✅ DONE. Transfer complete, A flipped to 44.231.156.226,
  TLS cert issued (CN=lilsproutdoodles.com), HTTPS 200 "Lil Sprout Doodles".
  **ROOT CAUSE of the earlier "down everywhere / website-b7bb0005 cert" symptom:**
  stale **DNSSEC** — the .com registry had 3 DS records (key tag 46010) from the old
  Bluehost DNS, but the new Route 53 zone is unsigned → broken chain of trust →
  validating resolvers (8.8.8.8, 9.9.9.9, Let's Encrypt) REFUSED to resolve it. The
  `website-b7bb0005.theschaufs.com` cert was Bluehost's, seen only via stale cache.
  **FIX:** removed all 3 DS records via `aws route53domains
  disassociate-delegation-signer-from-domain` (one op at a time) → DNSSEC now
  `unsigned` → resolvers recover (Cloudflare first; Google/Quad9 clear cached
  SERVFAIL over the old DS TTL, a few hours) → cert issued.
  **LESSON for any future transfer:** check `whois | grep DNSSEC` — if a transferred
  domain was DNSSEC-signed on the old DNS, you MUST remove the DS records at the
  registry (or sign the new zone), or it goes dark on validating resolvers. (None of
  the other 15 cut-over domains hit this — only lilsproutdoodles was signed.)
  **CLIENT-SIDE:** after the DS fix, Cloudflare (1.1.1.1) + OpenDNS cleared quickly but
  Google (8.8.8.8) / Quad9 held the cached SERVFAIL longer. Brad reconfigured his
  **router DNS to 1.1.1.1 / 1.0.0.1 (Cloudflare)** on 2026-10-08 so the LAN resolves it
  immediately. (Recorded in ~/.kiro/steering/steering.md.) The slower resolvers clear
  on their own within hours regardless.

---
(historical plan below)

**Status: Phases 1–4 done. Only cutover (Phase 6) + decommission (Phase 7) remain.**

Done:
- **Phase 1 DNS:** 18 Route 53 zones built + verified (records identical to Bluehost).
- **Phase 2 transfers:** 18 domains IN_PROGRESS at registrar (auto-approve window),
  incl. lilsproutdoodles.com (un-held + submitted 2026-10-04). No completions yet —
  check `./migration-data/check-transfers.sh`.
- **Phase 3 server:** `schauf-server` (Lightsail, 44.231.156.226, Ubuntu 22.04,
  NGINX+PHP8.3+MariaDB) live. SSH: `~/schaufserver.sh`.
- **Phase 4 sites:** ALL migrated + verified on schauf-server (14 NGINX blocks):
  5 WordPress, gladdenwatch (PHP+DB), 3 static, 2 placeholders, trial redirect,
  2 park pages. 72 GB bradschauf media on S3 (`bradschauf-media`) + CloudFront
  (`E2XK5VTX2AB0AM`, Deployed, verified serving).

**⚠️ KEY FINDING (2026-10-04): nameservers still on Bluehost — this gates certs & cutover.**
Phase 1 built the Route 53 zones but the registrar **nameserver flip was never
triggered** — public NS for all domains are still `ns1/ns2.bluehost.com`, so the world
resolves via Bluehost, not Route 53. Consequence:
- **DNS-01 certs** (certbot `--dns-route53`, from box OR Mac) FAIL — the ACME TXT lands
  in Route 53 but Let's Encrypt queries Bluehost's NS (NXDOMAIN). Blocked until NS flip.
- **HTTP-01 certs** (`certbot --nginx`, no creds needed) also need the domain's A record
  pointing at schauf-server first (currently → Bluehost 50.87.221.44).
- So certs are blocked by DNS pointing, NOT credentials. (The scoped IAM user/creds
  trialed on the box were deleted — HTTP-01 needs none.)

**Two ways nameservers move to Route 53:**
- (a) Let the in-flight registration transfers complete — Route 53 Domains auto-sets
  the zone's NS when each lands (~days). Then certs + cutover work.
- (b) Manually flip NS at the Bluehost portal now (per §5.1 NS sets) — safe/invisible
  (records identical), unblocks today, but redundant with the transfer.

**NEXT STEP — Phase 6 cutover (blocked on NS → Route 53 per above):**
1. Once a domain resolves via Route 53: flip its A record 50.87.221.44 → 44.231.156.226
   in the R53 zone, then `certbot --nginx` (HTTP-01, no creds) issues HTTPS. Per site.
   **EXCLUDE schaufwerks.com** (live Weebly commerce — stays on Bluehost; see §5.3).
2. Verify HTTPS + sites + ProtonMail mail; monitor 24–48h.
3. Then Phase 7 decommission — GATED on: schaufwerks replacement store live.
   (staging.catholicfunctions.com RECREATED later, not migrated — not a gate.)

Recommended: wait for transfers to complete (auto-sets NS), OR do a manual NS flip on
one low-stakes domain to pilot cutover today. Certbot + route53 plugin already installed
on the box (plugin now unused since HTTP-01 is the chosen path).

**Cutover-time cleanups:** bradschauf.com homepage from its GitHub repo + wire
`/videos/` → CloudFront; bradschauf SPF drop stale `+ip4:50.87.221.44`; update
`~/check-sites.sh` / `~/websites.json` monitoring targets.

**Separate (catholicfunctions project):** VPS retirement + Lightsail promotion/
right-sizing moved to `~/GitHub/catholicfunctions/VPS-RETIREMENT-AND-RIGHTSIZING.md`.

**Follow-ups:** gladdenwatch Google API keys — Brad opted NOT to rotate (low risk: Maps
key is already public in page source by design; real safeguard is referrer restriction
+ billing cap, not secrecy); rebuild schaufwerks.com (open-
source options: WooCommerce recommended — see below); build out theschaufs.com +
schauf.org; hand off sadff.com; delete `staging*/` dirs (~77 GB) after cutover.

Other docs: `server.schauf-server.md`, `websites.md`, `aws-cost-breakdown.md`,
`aws-rightsizing-plan.md`.

---

# (original plan below)


Migrating all personal websites off the old Bluehost shared hosting account
(`theschaufs.com`) and onto AWS account **566105881027**. Goal: **completely off
Bluehost** — DNS hosting, domain registration, website hosting, and email.

- **Source:** Bluehost shared hosting, cPanel account `theschau`
  - Host: `box2232.bluehost.com`, server public IP `50.87.221.44`
  - Home: `/home2/theschau`, ~94 GB used, PHP 8.3.35, MySQL
  - SSH: `ssh -i ~/.ssh/schauf.priv theschau@theschaufs.com` (helper: `~/theschaufs.sh`)
- **Target:** AWS account `566105881027`
  - DNS → Route 53 (hosted zones)
  - Registration → Route 53 Domains (transfer in)
  - Hosting → Lightsail instance (size TBD, see Open Decisions)
  - Email → TBD (see Open Decisions)

Status legend: ⬜ not started · 🔄 in progress · ✅ done · ⏭️ out of scope

---

## 0. Live HTTP status (checked 2026-10-03, informs what to migrate)

| Domain | HTTP | Note |
|---|---|---|
| bradschauf.com | 200 | live |
| jimnewmann.com | 200 | live |
| flightoftheshroud.com | 200 | live |
| trialoftheshroud.com | 200 | live (same content as flightoftheshroud) |
| indecisionranch.com | 200 | live (WordPress) |
| nathanschauf.com | 200 | live (static + /blog WP) |
| shelbieschauf.com | 200 | live (static + /blog WP) |
| shelbiestevenson.com | 200 | live (static + /blog WP) |
| lindaschauf.com | 200 | live |
| 2ndaob.com | 200 | live |
| gladdenwatch.com | 200 | live (PHP) |
| lilsproutdoodles.com | 200 | live static — NOW IN SCOPE: migrated to schauf-server + transfer submitted |
| schaufwerks.com | 404 | responds but root 404 — investigate at copy time |
| theschaufs.com | 403 | park-for-now (build later) |
| schauf.org | 403 | park-for-now (build later) |
| **wekenb.org** | **403** | **EXCLUDED — not serving, Brad does not want it moved** |

## 1. Inventory (captured read-only 2026-10-03)

### 1.1 Domains and where DNS lives today

All domains are **registered at Bluehost** and (unless noted) use Bluehost
nameservers `ns1/ns2.bluehost.com`. Two domains already run on Route 53 and are
out of scope for the DNS move.

| Domain | NS today | Notes |
|---|---|---|
| theschaufs.com | Bluehost | Main account domain |
| bradschauf.com | Bluehost | Also a GitHub-managed site; 88 GB media here (see 1.3) |
| jimnewmann.com | Bluehost | cPanel mailbox domain |
| schaufwerks.com | Bluehost | |
| indecisionranch.com | Bluehost | WordPress + cPanel mailbox |
| nathanschauf.com | Bluehost | WordPress blog + cPanel mailbox |
| shelbieschauf.com | Bluehost | WordPress blog + cPanel mailbox |
| shelbiestevenson.com | Bluehost | WordPress blog + cPanel mailbox |
| lindaschauf.com | Bluehost | cPanel mailbox |
| 2ndaob.com | Bluehost | cPanel mailbox (2 accounts) |
| gladdenwatch.com | Bluehost | PHP + cPanel mailbox |
| lilsproutdoodles.com | Bluehost | cPanel mailbox (1 account, 6.8 MB) |
| flightoftheshroud.com | Bluehost | cPanel mailbox |
| trialoftheshroud.com | Bluehost | No MX |
| schauf.org | Bluehost | Mail on **Google Workspace** |
| wekenb.org | Bluehost | WordPress (`wekenborg/`) + cPanel mailbox |
| schaufs.com | Bluehost | Parked; mail on **ProtonMail** |
| sadff.com | Bluehost | Parked (likely droppable — confirm) |
| catholicfunctions.com | **Route 53 (AWS)** ⏭️ | Already migrated; Laravel app |
| flockfunctions.com | **Route 53 (AWS)** ⏭️ | Already migrated |

### 1.2 Sites, docroots, and application type

Docroots under `/home2/theschau/public_html/` unless noted.

| Site / dir | Type | Disk | Notes |
|---|---|---|---|
| bradschauf/ | static + WordPress `blog/` | **88 GB** | Mostly media archive (see 1.3) |
| shelbiestevenson/ | static + WordPress `blog/` | 944 MB | |
| shelbieschauf/ | static + WordPress `blog/` | 681 MB | |
| indecisionranch/ | WordPress | 338 MB | |
| nathanschauf/ | static + WordPress `blog/` | 308 MB | |
| catholicfunctions_app/ | Laravel (+composer) | 255 MB | On Route 53 already ⏭️ |
| wekenborg/ | WordPress | 149 MB | Serves wekenb.org |
| brad/ | static | 127 MB | |
| schaufwerks/ | static | 98 MB | |
| flightoftheshroud/ | static | 55 MB | |
| shroud/ | static | 46 MB | |
| catholicfunctions/ | Laravel symlink | 19 MB | On Route 53 already ⏭️ |
| lilsproutdoodles/ | static | 12 MB | |
| wedding/ | static | 1.7 MB | |
| gladdenwatch/ | PHP | 1.3 MB | |
| 2ndaob/ | static | 540 KB | |
| jimnewmann/ | static | 264 KB | |
| lindaschauf/ | static | 96 KB | |
| schauf, site, web, wekenb, website_1237d0bb, bradschauf.com | static | small | Stubs/legacy |
| flockfunctions.com/ | static (16 KB) | 16 KB | On Route 53 already ⏭️ |

WordPress installs found (`wp-config.php`):
`indecisionranch/`, `shelbiestevenson/blog/`, `wekenborg/`, `bradschauf/blog/`,
`nathanschauf/blog/`, `shelbieschauf/blog/`.

Databases: MySQL present; sizes not yet dumped (needs DB creds from a wp-config —
pending). Old `.sql` backups litter the home dir from 2008–2025.

### 1.3 The 88 GB `bradschauf/` — resolved: split web vs. media

Investigated what the **live** homepage (`index.html`, rebuilt Jul 2026) actually
references. Result: the site itself is tiny; the bulk is a linked **family video
archive** plus unlinked legacy galleries.

**Actually part of the website (small):**
- `index.html` + root dog JPEGs + a PDF ≈ **30 MB**
- `blog/` (WordPress) = **2.2 GB**
- ~11 named feature videos in `videos/` (SL55, galas, white rabbit, etc.)

**Linked family home-movie archive (large but precious):**
- `videos/home/` = **54 GB** — digitized VHS 1993→ (births, baptisms,
  Christmases, McLaughlin family tribute). Linked from the homepage's video page.
  Files are 0.5–3 GB each.

**Unlinked legacy content (reachable only by direct URL, ~14 GB):**
- `Kayla/` 7.8 GB, `TFD25/`+`TFD26/` 3.8 GB, `gfhoa/` 1.1 GB, `porsche/`,
  `shane/`, `airtug/`, `work/`, `whiterabbit/`, `images/`, etc.

**Decision (recommended): split storage.**
- **Website** (index + blog + small assets, ~2.3 GB) → Lightsail instance disk.
- **Large media** (`videos/` incl. `videos/home/`, ~72 GB) → **S3**, served via
  **CloudFront**, keeping the same `bradschauf.com/videos/...` URLs via a path
  behavior. S3 is the right home for big static media: cheap, durable, scales,
  and doesn't bloat the web instance. Rationale: streaming multi-GB MP4s off a
  small Lightsail box is slow and risks the instance; S3+CloudFront is built for it.
- **Unlinked legacy** (~14 GB) → also S3 (same bucket, `glacier`/IA class if we
  want it cheap and rarely accessed), preserving URLs. Nothing gets deleted.

This drops the web instance's content footprint from ~88 GB to ~2.3 GB, so a
small Lightsail plan is plenty.

### 1.4 Email

| Mail provider | Domains | Action |
|---|---|---|
| ProtonMail | theschaufs.com, schaufs.com, bradschauf.com, schaufwerks.com | Safe — MX already off Bluehost; carry records to Route 53 |
| Google Workspace | schauf.org | Safe — carry MX to Route 53 |
| **Bluehost cPanel mail** | jimnewmann, indecisionranch, nathanschauf, shelbieschauf, shelbiestevenson, lindaschauf, 2ndaob, gladdenwatch, lilsproutdoodles, flightoftheshroud, wekenb.org | **Blocker** — real mailboxes on the server; must be rehomed or retired before leaving Bluehost |

cPanel mailbox accounts & sizes found:
2ndaob.com (2 accts, 5.6 MB), lilsproutdoodles.com (1, 6.8 MB),
schaufwerks.com (2), gladdenwatch.com (1, 1.2 MB), catholicfunctions.com (1, 644 KB — already on R53),
plus small/empty others. Full per-mailbox export needed before cutover.

### 1.5 Current DNS records to recreate in Route 53

Server A record for all Bluehost-hosted sites: **`50.87.221.44`** (will change to
the Lightsail static IP at cutover). Key non-default records to preserve:

- **theschaufs.com / schaufs.com:** MX ProtonMail; `www` → `ghs.google.com`;
  SPF `include:_spf.protonmail.ch`; protonmail-verification TXT
- **bradschauf.com:** MX ProtonMail; SPF; protonmail-verification TXT
- **schaufwerks.com:** MX ProtonMail; SPF; protonmail-verification TXT
- **schauf.org:** MX Google (`aspmx.l.google.com` et al.); SPF; `www` A
- **jimnewmann / 2ndaob / gladdenwatch / lilsproutdoodles / flightoftheshroud /
  indecisionranch / nathanschauf / shelbieschauf / shelbiestevenson / lindaschauf /
  wekenb.org:** MX → `mail.<domain>` (Bluehost); SPF includes bluehost/websitewelcome;
  `www` A → 50.87.221.44
- Full zone exports (all records, TTLs) to be captured per-domain during Phase 1.

---

## 2. Migration plan (phased)

### Phase 0 — Decisions & access ✅/⬜
- [x] Resolve decisions (see §3): media→split S3, cPanel email→abandon, stack→$12 Ubuntu, transfers→Path A, access→default CLI, keep all domains.
- [x] AWS access confirmed: default CLI profile → account 566105881027 (`brad-admin`), us-west-2.
- [ ] Lower DNS TTLs at Bluehost to 300s a day before any cutover.

### Phase 1 — DNS to Route 53 (no visible change) ⬜
Move DNS *hosting* first; nameserver switch is the only externally visible step
and it keeps pointing at the same Bluehost IP, so nothing breaks.
- [ ] Capture full zone export for each in-scope domain (all record types + TTLs).
- [ ] Create a Route 53 hosted zone per domain in account 566105881027.
- [ ] Recreate every record exactly (A → 50.87.221.44 for now, MX/TXT/CNAME/SPF as-is).
- [ ] Verify Route 53 answers match Bluehost (`dig @<r53-ns>` vs. current).
- [ ] At the registrar (Bluehost), repoint nameservers to the zone's Route 53 NS set, one domain at a time.
- [ ] Confirm propagation; sites and mail unchanged because records are identical.

### Phase 2 — Domain registration transfer to Route 53 Domains ⬜
Independent of DNS hosting; can run in parallel/after Phase 1.
- [ ] Unlock each domain at Bluehost, disable WHOIS privacy if it blocks transfer, get auth/EPP codes.
- [ ] Initiate transfer-in to Route 53 Domains (566105881027). Note: `.org` and `.com` ~$ transfer fee each, adds 1 yr registration.
- [ ] Approve transfer emails; wait up to 5–7 days per domain.
- [ ] Keep Route 53 nameservers set during transfer (transfer does not change DNS if NS already on R53).

### Phase 3 — Provision Lightsail hosting ⬜
- [ ] Create Lightsail instance in 566105881027 (blueprint & size per decision).
- [ ] Attach a static IP.
- [ ] Base config: web server (NGINX/Apache), PHP 8.3, MySQL/MariaDB, certbot for Let's Encrypt.
- [ ] Attach a block-storage disk sized for content (depends on media decision).
- [ ] Harden: SSH key auth only, firewall to 22/80/443, automatic security updates.

### Phase 4 database inventory (Bluehost, 2026-10-04)

| Site | DB name | Size | Tables | WP prefix |
|---|---|---|---|---|
| indecisionranch | theschau_452 | 3.2 MB | 21 | 452_ |
| nathanschauf | theschau_ss_dbname24e | 0.7 MB | 24 | wp_qeoj_ |
| shelbieschauf | theschau_a16 | 0.8 MB | 20 | a16_ |
| shelbiestevenson | theschau_ss_dbname096 | 1.1 MB | 20 | wp_dmbg_ |
| bradschauf (blog) | theschau_ss_dbnamea75 | 2.7 MB | 17 | wp_zdpe_ |
| gladdenwatch (PHP) | theschau_gladdenwatch | — | — | n/a |

All DBs tiny (~8.5 MB total for WP). DB creds live in each site's wp-config.php /
config.php (not recorded here; extracted on the fly into gitignored files at dump).
`DB_HOST=localhost` on all. gladdenwatch config also holds Google Maps/Geocoding
API keys and ADMIN_EMAIL — **rotate the Google API keys post-migration** (they were
briefly surfaced during inventory).

### Phase 4 — Migrate sites & data ⬜

**What moves to Lightsail (every site on the shared server, by type):**
- **WordPress (files + MySQL DB each):** indecisionranch.com, nathanschauf.com,
  shelbieschauf.com, shelbiestevenson.com, bradschauf.com (blog). WP needs DB
  export/import + wp-config + site-URL fix.
  - **wekenb.org — EXCLUDED** (site returns 403, not serving; Brad does not want it
    moved). Its WordPress at `wekenborg/` is NOT migrated.
- **PHP (files + check for DB):** gladdenwatch.com (live PHP site — confirm whether
  it has a MySQL DB during Phase 4 inventory).
- **Static (file copy only):** jimnewmann.com, flightoftheshroud.com, 2ndaob.com,
  lindaschauf.com, schaufwerks.com, plus smaller dirs (brad/, shroud/, wedding/, etc.).
- **Park-for-now:** theschaufs.com, schauf.org — now have "coming soon" placeholder
  pages + NGINX blocks on schauf-server (200), ready for a future build.
- **Special:** bradschauf.com media (72 GB) → S3 + CloudFront, NOT Lightsail.
- **NOT moving:** sadff.com (stays on Squarespace), catholicfunctions.com /
  flockfunctions.com / staging (hands-off / cross-project, see §5.3a–b).

- [x] Sync static sites to `/var/www/<domain>/public` on schauf-server (rsync via local staging; 8s spacing to avoid cPHulk). Verified on server via Host-header curl:
  - jimnewmann.com ✅ 200, flightoftheshroud.com ✅ 200, 2ndaob.com ✅ 200
  - trialoftheshroud.com ✅ → 301 redirect to flightoftheshroud.com (it only redirected on Bluehost; no content to migrate)
  - lindaschauf.com ✅ — no real site existed (empty default.html). Added a blank
    `index.html` placeholder → 200. Fine as-is.
  - schaufwerks.com ✅ — **wife's store**, now a static render on AWS over HTTPS
    (recovered 2026-10-15). See §5.4b for the full recovery. **TODO: real store
    rebuild with wife (WooCommerce rec.).**
- [x] WordPress sites (5) migrated to schauf-server: files rsync'd, DBs imported,
  wp-config DB passwords updated. All verified on server (no DB errors):
  - indecisionranch.com → WP at docroot; 301→https (correct, needs cert at cutover)
  - nathanschauf.com/blog → "Nathan Schauf — Coming Soon" ✅
  - shelbieschauf.com/blog → "Sheblie Schauf Blog" ✅
  - shelbiestevenson.com/blog → "Shelbie Stevenson" ✅
  - bradschauf.com/blog → "Schauf Blog" ✅
  - DB names/users kept identical to Bluehost; only passwords regenerated
    (gitignored `secrets/db-users.env`). siteurl/home already correct in DBs
    (indecisionranch.com, nathanschauf.com/blog, etc.) — no URL rewrite needed.
- [x] gladdenwatch.com (PHP) migrated: files + DB (`theschau_gladdenwatch`, 9 tables
  w/ data), config DB password updated, NGINX block with sensitive-file guards.
  Verified live (title "GladdenWatch — Home", no DB errors). NOTE: repo-managed —
  reconcile with its GitHub repo + deploy script later.
- [x] **bradschauf.com media → S3 + CloudFront (COMPLETE 2026-10-04):**
  - S3 bucket **`bradschauf-media`** (us-west-2), public access fully blocked.
  - Upload: `videos/` (72 GB, **98 files — all synced**) via `media-to-s3.sh`
    (rsync Bluehost→Mac, then `aws s3 sync` → `s3://bradschauf-media/videos/`).
    Key structure preserved → S3 keys are `videos/...`.
  - **Verified:** CloudFront serves media (HTTP 200, content-type video/mp4);
    direct S3 access correctly blocked (403). CloudFront status = Deployed.
  - CloudFront OAC `EMCEAVQH5M36H`; distribution **`E2XK5VTX2AB0AM`** at
    `d1xmnyfjt1ssl3.cloudfront.net` (redirect-to-https, GET/HEAD, compress,
    CachingOptimized policy, PriceClass_100). Bucket policy restricts reads to this
    distribution only (OAC).
  - **Wiring to bradschauf.com/videos/ (at cutover):** either (a) add `bradschauf.com`
    as a CloudFront alias with an ACM cert and route `/videos/*` to CloudFront at the
    edge, or (b) NGINX on schauf-server `proxy_pass` `/videos/` → the CloudFront
    domain. URLs stay `bradschauf.com/videos/...` either way. Decide at cutover.
  - IDs saved in `migration-data/secrets/cloudfront-*.{id,txt}`.
  - [ ] Keep small site assets (index, dog JPEGs, blog) on Lightsail (done for blog;
    homepage comes from repo).
- [ ] Configure NGINX server blocks per domain; issue Let's Encrypt certs for each.
- [ ] Test every site against the Lightsail IP via `/etc/hosts` override before cutover.

### Phase 5 — Email (abandon cPanel mail) ⬜
- [ ] For the 11 cPanel-mail domains: **do not** recreate `mail.<domain>` MX in Route 53 (mail intentionally dropped — Brad doesn't use these).
- [ ] Preserve mail for ProtonMail domains (theschaufs, schaufs, bradschauf, schaufwerks): carry MX + SPF + protonmail-verification TXT into Route 53 exactly.
- [ ] Preserve mail for schauf.org (Google Workspace): carry MX + SPF TXT into Route 53 exactly.
- [ ] (Optional courtesy) export any cPanel mailbox before cancellation during Phase 7 backup.

### Phase 6 — Cutover ⬜
- [x] ~~EXCLUDE schaufwerks.com from cutover~~ — SUPERSEDED 2026-10-15. Bluehost broke
  the Weebly store post-transfer, so the "keep it live on Bluehost" plan was moot. Flipped
  it to AWS as a static render (A → 44.231.156.226, HTTPS live). See §5.4b. Commerce
  rebuild deferred.
- [x] Per site, change the Route 53 A record from 50.87.221.44 → schauf-server static IP `44.231.156.226` (incl. schaufwerks.com, 2026-10-15).
- [ ] Verify HTTPS, forms, WordPress admin, mail flow.
- [ ] Monitor for 24–48 h.
- [ ] Update `~/check-sites.sh` / `~/websites.json` monitoring + the steering "Monitored Sites" list to point at the new server where relevant.
- [ ] Clean up bradschauf.com SPF (`+ip4:50.87.221.44` → remove the dead Bluehost IP).

### Phase 7 — Decommission Bluehost ⬜
- [ ] Confirm all domains, sites, and mailboxes fully served from AWS.
- [ ] **GATE: `staging.catholicfunctions.com` moved off the shared server** (it's on `50.87.221.44`, THIS server — see §5.3b) — move to the catholicfunctions VPS or temporarily to personal Lightsail before cancelling the shared account, or staging breaks.
- [x] ~~GATE: schaufwerks.com replacement store LIVE~~ — CLEARED 2026-10-15. schaufwerks.com
  is off Bluehost (static render on AWS over HTTPS, see §5.4b). The old Weebly commerce is
  gone either way (Bluehost broke it). No remaining schaufwerks dependency on Bluehost.
  (Real store rebuild with wife is a separate follow-up, NOT a decommission gate.)
- [ ] Confirm sadff.com DNS flipped to Route 53 + registration in Brad's custody (so it survives Bluehost closure; see §5.3).
- [ ] Take a final full backup of the Bluehost account (archive locally).
- [ ] Cancel Bluehost hosting; confirm all registrations transferred out.

---

## 3. Decisions (resolved 2026-10-03)

1. **88 GB media** → ✅ **Split.** Website files stay on Lightsail; `videos/`
   (incl. 54 GB family archive) + unlinked legacy galleries move to **S3 +
   CloudFront**, preserving `bradschauf.com/videos/...` URLs. Nothing deleted.
   (See §1.3.) Verified that only ~2.3 GB is the actual site.

2. **11 Bluehost cPanel mailboxes** → ✅ **Abandon.** Brad does not use these
   email domains and does not care about the mail. Action: at cutover we simply
   do **not** recreate `mail.<domain>` MX records in Route 53 for these domains.
   Mailbox contents on Bluehost are discarded with the account. (A courtesy final
   export can be taken during the backup step, but is not required.)
   Affected: jimnewmann, indecisionranch, nathanschauf, shelbieschauf,
   shelbiestevenson, lindaschauf, 2ndaob, gladdenwatch, lilsproutdoodles,
   flightoftheshroud, wekenb.org.
   **Keep** mail working for ProtonMail domains (theschaufs, schaufs, bradschauf,
   schaufwerks) and the Google domain (schauf.org) — carry those MX/TXT as-is.

3. **Lightsail size & stack** → see §3.1 (pros/cons + cost). Recommendation
   below; final tier your call.

4. **Domain transfers** → see §3.2 (pros/cons + cost). Recommendation: move DNS
   first, transfer registrations in a batch after DNS is verified.

5. **AWS access** → ✅ **Resolved.** Default CLI profile works:
   `aws sts get-caller-identity` → account **566105881027**, user `brad-admin`,
   region **us-west-2**. I can script Route 53, S3, CloudFront, and Lightsail.

6. **Droppable domains** → ✅ **Retain all for now.** Brad owns them; keep
   ownership. We transfer registration of every owned domain and do not let any
   lapse during this migration. (`sadff.com` / `trialoftheshroud.com` /
   parked domains included — confirm Bluehost shows them as owned during transfer.)

### 3.1 Lightsail sizing & stack — pros/cons + cost

With media offloaded to S3, the web instance only serves ~2.3 GB (static sites +
6 WordPress blogs + a couple PHP pages). CPU/RAM, not disk, is the constraint —
WordPress + PHP + MySQL on one box.

Lightsail Linux plans (us-west-2, fixed monthly, includes data transfer):

| Plan | RAM | vCPU | SSD | ~Cost/mo | Fit |
|---|---|---|---|---|---|
| $5  | 512 MB | 2 | 20 GB | $5 | Too small for 6 WP + MySQL |
| $7  | 1 GB | 2 | 40 GB | $7 | Tight but workable for light traffic |
| **$12** | **2 GB** | **2** | **60 GB** | **$12** | **Recommended** — comfortable for all WP blogs + MySQL + headroom |
| $24 | 4 GB | 2 | 80 GB | $24 | Only if traffic/WP plugins demand it |

**Stack options:**

- **Plain Ubuntu 22.04 LTS + NGINX + PHP 8.3 + MariaDB (managed by us)** —
  *Recommended.*
  - Pros: full control; one box hosts all ~15 small sites via server blocks;
    matches the PHP 8.3 already on Bluehost; easy Let's Encrypt via certbot;
    clean, reproducible, scriptable; no vendor lock-in.
  - Cons: we configure/patch it ourselves (manageable; can add unattended-upgrades).
- **Lightsail "WordPress" blueprint (Bitnami)**
  - Pros: WP preinstalled.
  - Cons: single-site oriented, Bitnami's opinionated layout is awkward for
    6 WP installs + many static sites on one box; harder to host the non-WP sites.
    Not a good fit for a mixed portfolio.
- **Lightsail "LAMP" blueprint (Bitnami)**
  - Pros: Apache+PHP+MySQL preinstalled.
  - Cons: Bitnami path conventions add friction vs. a clean Ubuntu box.

**Recommendation:** **$12/mo (2 GB) Ubuntu 22.04 + NGINX + PHP 8.3 + MariaDB**,
one static IP, hosting every site via NGINX server blocks. Start here; resizing
up is a snap-restore away if needed.

### 3.2 Domain registration transfer — pros/cons + cost

~19 domains, currently registered at Bluehost. Two paths:

**A) Move DNS to Route 53 first, transfer registrations after (recommended).**
- Pros: DNS hosting on Route 53 is independent of who the registrar is; we get
  the whole portfolio onto Route 53 zones and validated against the live site
  with zero risk, *then* transfer registration at our own pace. If a transfer
  stalls (common with registrar locks/approvals), the site/DNS is unaffected.
- Cons: two steps instead of one; Bluehost remains the registrar briefly.

**B) Transfer registrations and DNS together.**
- Pros: one pass.
- Cons: couples a slow, approval-gated process (5–7 days/domain) to DNS; a stuck
  transfer complicates the DNS picture. More fragile.

**Costs (ICANN rules):** a domain transfer-in charges one year's registration and
*adds* a year to the current expiry (you don't lose time). Approx. per domain at
Route 53 Domains: **`.com` ≈ $14/yr, `.org` ≈ $12/yr, `.net` ≈ $14/yr** (prices
vary slightly; confirm at transfer time). Portfolio is mostly `.com` + two `.org`
(`schauf.org`, `wekenb.org`). Rough one-time total for ~19 domains ≈ **$250–280**,
and it covers the next year of registration for each. Ongoing renewals at Route 53
are comparable to Bluehost, often cheaper than Bluehost's post-promo rates.

**Requirements per domain before transfer:** unlock at Bluehost, obtain the
auth/EPP code, ensure the domain is >60 days since last transfer/registration,
and a reachable admin contact email to approve. WHOIS privacy may need toggling.

**Recommendation:** Path A. Phase 1 (DNS) now; Phase 2 (transfers) as a batch
once DNS is verified, keeping Route 53 NS set so DNS is untouched by the transfer.

### 3.3 S3 + CloudFront media cost (bradschauf.com)

~72 GB of video archive offloaded to S3, fronted by CloudFront:
- **S3 Standard storage:** ~72 GB × ~$0.023/GB ≈ **$1.70/mo**. (Legacy/unlinked
  ~14 GB could drop to S3 Standard-IA or Glacier for pennies if rarely watched.)
- **CloudFront egress:** pay per GB streamed; first 1 TB/mo is ~$0.085/GB. For a
  personal family-video site with low traffic, realistically **a few dollars/mo**.
- No instance disk needed for media; the Lightsail box stays small.

Combined steady-state estimate: **Lightsail $12 + S3/CloudFront ~$5 ≈ $17/mo**,
plus the one-time ~$250–280 of domain transfers (which prepay a year each).

## 3.7 Follow-up / cleanup TODOs

- **Repo cleanup:** `migration-data/staging/`, `staging-wp/`, `staging-media/`,
  `*.log`, and `zonefiles/` are gitignored (they hold GBs of migrated site files +
  the 72 GB media pull, and tripped the editor's "too many active changes" warning).
  Git now sees only docs + small scripts/reference data. Local staging footprint:
  `staging/` ~154 MB (static sites), `staging-wp/` ~4.3 GB (WP sites + wp-configs),
  `staging-media/` ~72 GB (bradschauf videos). **Safe to delete all `staging*/` once
  cutover is verified** — they are copies, not the source of truth.
  Tracked in repo: `*.sh` scripts, `records/`, `r53-batches/`, `zone-ids/`,
  `ns-sets/`, `cf-distribution.json`, `fix-wpconfig.php`.
  Gitignored secrets: `secrets/` (auth codes, DB passwords, SSH key refs, CloudFront
  IDs), `contact.json`.
- **Per-site git repos + deploy scripts.** Repo-managed sites (GitHub, with deploy
  scripts currently targeting Bluehost): **jimnewmann.com, gladdenwatch.com,
  flightoftheshroud.com, bradschauf.com** (+ catholicfunctions.com = out of scope).
  For these, the **git repo is the source of truth for CODE** — the rsync'd Bluehost
  copies now on schauf-server are functional stand-ins only. DB + `wp-content/uploads`
  always come from the live server regardless (not in git).
  **TODO (walkthrough with Brad):** re-point each repo's deploy script at schauf-server
  (`44.231.156.226`, `/var/www/<domain>/public`) and redeploy from the repo.
  - The **5 WordPress sites are NOT in repos** (indecisionranch, nathanschauf/blog,
    shelbieschauf/blog, shelbiestevenson/blog, bradschauf/blog) → the pulled files
    ARE authoritative; safe to push directly.
  - **bradschauf.com splits 3 ways:** homepage = GitHub repo; `/blog` = WordPress
    (Bluehost pull); `/videos` media = S3+CloudFront.
- **gladdenwatch Google API keys** — surfaced during inventory. Brad opted NOT to
  rotate (acceptable: Maps key is public-by-design in browser page source; Geocoding
  key is server-side; the real protection is HTTP-referrer restriction + billing quota,
  not secrecy). Optional: confirm referrer restriction + billing cap in Google Cloud
  Console sometime.
- **schaufwerks.com real store rebuild** — static render is live on AWS (§5.4b); a working
  e-commerce rebuild (WooCommerce rec.) is still TODO, to plan WITH wife.

## 3.8 Backlog (consider, not committed)

- **Google Search Console: consolidate to Domain properties.** Currently each site is
  a URL-prefix property (`https://<domain>/`), which only covers that exact scheme+host.
  A **Domain property** (verified by one DNS TXT in Route 53) covers the whole domain —
  all subdomains + http/https — in a single view. Nice-to-have tidy-up now that sites are
  multi-part (e.g. bradschauf.com = homepage + /blog + /videos). All current URL-prefix
  properties are already verified and working, so this is optional, not a fix. If done:
  Search Console → Add property → Domain → it issues a TXT → add to Route 53 → verify.
  Applies to the 4 verified properties: bradschauf.com, jimnewmann.com,
  catholicfunctions.com, flockfunctions.com.

## 3.9 "Dark" galleries under bradschauf/ (migrated 2026-10-11)

The old `public_html/bradschauf/` had ~13 GB of UNLINKED content ("dark sites" — served
but no links point to them; URL-only access) that the original site-focused migration
missed. Caught before Bluehost cancellation and migrated to schauf-server
`/var/www/bradschauf.com/public/<dir>/`, preserving the `bradschauf.com/<dir>/` URLs
and the dark/unlinked behavior. Dirs: Kayla (7.8G), TFD26 (2.3G), TFD25 (1.3G),
gfhoa (1.1G), work, porsche, shane, airtug, images, gigi, auntkaren, Ringtones,
parenting, voice, Lizzie, 2026alaska, resume, 911, edgestone-nw, euro-monkey,
son-in-law-interview, oldsite, web, HCR26, packages. Verified serving over HTTPS.
Local backup in `migration-data/staging-dark/`. whiterabbit/ (518M, 267 startup
screenshots) migrated the same way earlier.
- **TODO (later):** fold these into the bradschauf.com repo (its own GitHub repo) so
  they're version-controlled + deploy via deploy.sh, rather than living only on the
  server. Not urgent — they're safe and serving now.
- **LESSON:** site migrations that follow only linked content miss "dark" URL-only
  dirs. Before decommissioning any old host, `ls`/`du` the full docroot and reconcile
  EVERY subdir against what's migrated — don't rely on what the homepage links to.
- **NGINX autoindex for dark galleries:** old Bluehost (Apache) had directory listing
  ON by default, so browsing a gallery dir like `/Kayla/` showed a clickable file list.
  NGINX defaults listing OFF → bare dir URLs returned 403. Fixed by adding an
  `autoindex on` location block (regex-scoped to ONLY the gallery dir names) in
  `/etc/nginx/sites-available/bradschauf.com`, so `/Kayla/` etc. list files again
  while the homepage/blog/root are unaffected. Config backed up as `.bak.<ts>` on the
  server. If bradschauf.com's nginx config is ever regenerated/replaced, re-add that
  autoindex block or these dir listings will 403 again.

## 4. Notes
- catholicfunctions.com and flockfunctions.com are already on Route 53 and hosted
  separately; excluded from this migration except as reference.
- `catholicfunctions_app/` on the server contains its own Bluehost-exit docs
  (`BLUEHOST-CANCELLATION-TICKET.md`, `EMERGENCY-FAILOVER.md`) — useful reference
  for the cancellation step.

---

## 5. Phase 1 results — DNS live in Route 53 (2026-10-03)

**Status:** ✅ All 18 hosted zones created in account 566105881027 and populated
with records verified to answer **identically** to Bluehost. Nothing is visible
to the world yet — the registrar still points at Bluehost nameservers. The next
step (flip nameservers at Bluehost) is a deliberate per-domain go/no-go.

**How records were sourced:** Bluehost SSH got IP-blocked (cPHulk) after a burst
of connections, so records were pulled read-only via `dig @ns1.bluehost.com` for
every domain and type. No server changes made. Captured records in
`migration-data/records/`, generator in `migration-data/build-r53-batches.sh`,
change-batches in `migration-data/r53-batches/`, zone IDs in
`migration-data/zone-ids/`.

**Policy applied (final):**
- apex A + `www` kept at `50.87.221.44` (changes at cutover).
- ProtonMail mail preserved exactly (MX + SPF + protonmail-verification + _dmarc):
  theschaufs.com, schaufs.com, bradschauf.com, schaufwerks.com.
- All other mail dropped (cPanel mailboxes + schauf.org Google Workspace — Google
  no longer used).
- Dropped: `ghs.google.com` CNAMEs (were breaking `www`), `google-site-verification`
  TXT, and cPanel service hostnames (cpanel/webmail/ftp/mail/autodiscover/autoconfig).

### 5.1 Hosted zones + Route 53 nameservers (set these at the Bluehost registrar)

| Domain | Hosted Zone ID | Route 53 Nameservers |
|---|---|---|
| theschaufs.com | Z00507342HW80IPFGY535 | ns-904.awsdns-49.net, ns-380.awsdns-47.com, ns-1173.awsdns-18.org, ns-1904.awsdns-46.co.uk |
| bradschauf.com | Z03549351NX3U9KFA7HHS | ns-525.awsdns-01.net, ns-246.awsdns-30.com, ns-1178.awsdns-19.org, ns-1904.awsdns-46.co.uk |
| schaufs.com | Z01410112DNNV8KRZHISN | ns-873.awsdns-45.net, ns-1455.awsdns-53.org, ns-320.awsdns-40.com, ns-1585.awsdns-06.co.uk |
| schaufwerks.com | Z014246725GRRWDVD6HUF | ns-1470.awsdns-55.org, ns-1784.awsdns-31.co.uk, ns-390.awsdns-48.com, ns-987.awsdns-59.net |
| jimnewmann.com | Z01424641XCKAIZH31HAW | ns-1077.awsdns-06.org, ns-522.awsdns-01.net, ns-1618.awsdns-10.co.uk, ns-66.awsdns-08.com |
| flightoftheshroud.com | Z01192121XM703MRHUHPV | ns-1171.awsdns-18.org, ns-448.awsdns-56.com, ns-549.awsdns-04.net, ns-1613.awsdns-09.co.uk |
| schauf.org | Z00512432C634MBN07BJ6 | ns-1609.awsdns-09.co.uk, ns-826.awsdns-39.net, ns-345.awsdns-43.com, ns-1501.awsdns-59.org |
| indecisionranch.com | Z01409663VKLT2V55HVLL | ns-1715.awsdns-22.co.uk, ns-1145.awsdns-15.org, ns-591.awsdns-09.net, ns-26.awsdns-03.com |
| nathanschauf.com | Z01400803788DHSFTI8HL | ns-1920.awsdns-48.co.uk, ns-531.awsdns-02.net, ns-454.awsdns-56.com, ns-1488.awsdns-58.org |
| shelbieschauf.com | Z01412151IL0QMGE66BXZ | ns-344.awsdns-43.com, ns-1876.awsdns-42.co.uk, ns-1042.awsdns-02.org, ns-535.awsdns-02.net |
| shelbiestevenson.com | Z07010701XMQ688R2WN6T | ns-174.awsdns-21.com, ns-734.awsdns-27.net, ns-1233.awsdns-26.org, ns-1586.awsdns-06.co.uk |
| lindaschauf.com | Z03603064M6OO0LUAOZB | ns-690.awsdns-22.net, ns-1182.awsdns-19.org, ns-1718.awsdns-22.co.uk, ns-401.awsdns-50.com |
| 2ndaob.com | Z069161712XLN5SZ6HLQV | ns-1085.awsdns-07.org, ns-1900.awsdns-45.co.uk, ns-924.awsdns-51.net, ns-444.awsdns-55.com |
| gladdenwatch.com | Z0702339143HM2TYDNKIC | ns-411.awsdns-51.com, ns-1291.awsdns-33.org, ns-1615.awsdns-09.co.uk, ns-976.awsdns-58.net |
| lilsproutdoodles.com | Z07023433DPNRAMNTXXJX | ns-170.awsdns-21.com, ns-1273.awsdns-31.org, ns-1816.awsdns-35.co.uk, ns-926.awsdns-51.net |
| trialoftheshroud.com | Z0691158396YGRSG74EZI | ns-1269.awsdns-30.org, ns-687.awsdns-21.net, ns-1808.awsdns-34.co.uk, ns-405.awsdns-50.com |
| wekenb.org | Z01396051LPD52GCIALVY | ns-1410.awsdns-48.org, ns-2023.awsdns-60.co.uk, ns-73.awsdns-09.com, ns-585.awsdns-09.net |
| sadff.com | Z03524981OXTS4F5RAVEM | ns-1667.awsdns-16.co.uk, ns-1347.awsdns-40.org, ns-902.awsdns-48.net, ns-481.awsdns-60.com |

### 5.2 Verification

All 18 zones queried against their own Route 53 nameservers and compared to live
Bluehost answers:
- apex A = `50.87.221.44` on all (matches Bluehost).
- ProtonMail domains: MX = `10 mail.protonmail.ch` / `20 mailsec.protonmail.ch`,
  SPF + protonmail-verification present (matches Bluehost).
- All other domains: MX empty (mail intentionally dropped), `www` resolves to server.

### 5.3 sadff.com — IN SCOPE: move off Bluehost into Brad's custody, hand off later

sadff.com is **not** on the Bluehost server — it is hosted on Squarespace
(A `198.49.23.144/145`, `198.185.159.144/145`; `www` → `ext-cust.squarespace.com`).

**Constraint:** Bluehost is being cancelled **completely**, but the sadff.com
handoff to its eventual owner (recipient TBD) will take longer than that. So
sadff.com must **not** keep depending on Bluehost for either DNS or registration —
both die when the account closes. Therefore sadff.com stays **in scope** and
migrates like every other domain, just parked for eventual handoff:

- **DNS:** flip nameservers to the Route 53 zone built in Phase 1
  (`Z03524981OXTS4F5RAVEM`), which already holds the exact Squarespace records —
  sadff.com keeps resolving to Squarespace with no interruption, now independent
  of Bluehost.
- **Registration:** transfer into Brad's Route 53 Domains (Phase 2) so the domain
  survives Bluehost's closure. Brad holds it in custody.
- **Hosting:** unchanged — stays on Squarespace. Not moved to Lightsail.
- **TODO (later):** hand sadff.com off to the eventual owner once identified
  (transfer registration out of Brad's AWS account to them).

### 5.3a Explicitly out of scope — DO NOT TOUCH

These are already on their own Route 53 setup and must not be modified in any way:
- **catholicfunctions.com** (existing zone `Z01297893A06G98TVRUAT`)
- **flockfunctions.com** (existing zone `Z02485823PZFBFKZFN6W`)
- **backup.catholicfunctions.com** (subdomain record inside the catholicfunctions zone)

Phase 1 did **not** create or alter any of these; the 18 Phase 1 zones are all
separate domains.

### 5.3b ⚠️ BLOCKER — staging.catholicfunctions.com is on THIS server

**Must be resolved BEFORE the shared Bluehost account is cancelled, or it goes dark.**

**Two Bluehost servers exist (important context):**
- **Shared hosting** — `box2232.bluehost.com` / `50.87.221.44`. This is the server
  THIS migration decommissions. All personal sites live here.
- **VPS** — `catholicfunctions.com` prod resolves to `129.121.119.87`
  (`129-121-119-87.unifiedlayer.com`, Bluehost VPS). Brad handles the VPS later as
  a separate project. Prod catholicfunctions.com is NOT on the shared server.

**The catch:** `staging.catholicfunctions.com` resolves to **`50.87.221.44`** =
the **shared server we are decommissioning now** (verified via reverse DNS →
`box2232.bluehost.com`). So catholicfunctions **prod is on the VPS**, but its
**staging got placed on the shared box** — the one dying in this migration. It is
the live Laravel app at `~/public_html/catholicfunctions_app/` (255 MB). Its DNS A
record lives in the hands-off catholicfunctions.com Route 53 zone
(`Z01297893A06G98TVRUAT`).

**Decision:** staging must keep existing and be moved **off the shared server
before cancellation.** Target home: alongside prod on the catholicfunctions **VPS**
(natural fit) when Brad tackles the VPS project — or temporarily onto Brad's new
personal Lightsail box to get it off the dying shared server, then relocated to the
VPS later. (It's small, ~255 MB.) Recreating staging fresh on the VPS is also valid
if the current staging state is disposable.

**Ownership:** the staging *app* move belongs to the **catholicfunctions project**
(its deploy process, `.env`, DB; repo has `BLUEHOST-CANCELLATION-TICKET.md`,
`EMERGENCY-FAILOVER.md`). This doc only flags it as a hard gate on cancelling the
shared account.

**Feasibility note:** two Laravel apps on one host is routine — separate NGINX
server block, DB, `.env`, deploy dir, keyed by domain. Needs host headroom and
strict staging/prod DB separation.

### 5.4 Site-priority tiers (for Phase 4 cutover care)

- **Tier 1 (used, verify most carefully):** bradschauf.com, jimnewmann.com, flightoftheshroud.com
- **Tier 2 (lower use):** everything else.

### 5.4b schaufwerks.com — store recovery onto AWS (2026-10-15)

**Background.** schaufwerks.com (wife's store) was a live Weebly commerce site that we
deliberately kept on Bluehost during cutover (cart/checkout ran through Weebly's dynamic
`w_api/Handler.php`). After the registrar transfer completed, **Bluehost broke it** — it
served the `*.bluehost.com` fallback cert and a Weebly "Error. Page cannot be displayed"
page. The store was effectively dead on Bluehost with no path to fix it (needed Bluehost
root/WHM we don't have). Goal shifted to: **preserve all content on AWS and get the store
to at least RENDER** (full commerce rebuild deferred, to be done with wife).

**Content preserved in 3 places** (160 files, 97 MB — mostly product photos):
- Local: `migration-data/staging-schaufwerks/` (gitignored — large binaries; S3 is the
  durable copy).
- S3: `s3://schaufwerks-archive/schaufwerks-site/` (private bucket, 160 objects).
- Server: `/var/www/schaufwerks.com/public/` on schauf-server.

**The gap.** The static Bluehost export only had `about.html` + `contact.html` as real
pages. Home/Shop/Blog were Weebly-*dynamic* (listed in `w_api/w_published_data.txt` as
`"dynamic": true`) and never existed as static files — the server's `index.html` was a
234-byte Weebly redirect stub, and `shop.html` didn't exist at all.

**Recovery via Wayback Machine.** Pulled the raw original HTML (using the `id_` suffix:
`https://web.archive.org/web/<timestamp>id_/<url>` — gives the original with no Wayback
toolbar injection, verified 0 rewrites) for the 2023 captures that match our export's
Weebly generation:
- `index.html` ← snapshot `20230119215503`
- `shop.html` ← snapshot `20230408140921`
Both reference `/files/main_style.css` + `/uploads/.../` images — **all present** in our
preserved copy. about.html + contact.html kept from the export (newer 2025 builds). Blog
dropped (never captured; per Brad's call — the `/blog.html` nav link now 404s harmlessly).
(Wayback also had an older 2019 WordPress-era generation — `/blankets/`, `/block-signs/`,
`/luminaries/`, `/night-lights/` — NOT used; it predates the live Weebly store.)

**Assembly + go-live.**
1. Dropped the recovered `index.html` + `shop.html` into `/var/www/schaufwerks.com/public/`
   (old Weebly stub backed up to `index.html.weebly-stub.bak`), www-data:www-data 644.
2. Verified every local asset resolves + all 4 pages serve 200 (Host-header curl on the box).
   Existing NGINX block (`/etc/nginx/sites-available/schaufwerks.com`) already pointed at
   the right docroot.
3. Flipped R53 apex A `50.87.221.44` → `44.231.156.226` (TTL 300; www CNAME follows apex;
   ProtonMail MX/SPF/DKIM/DMARC untouched). Change `C03105032E7BO4SYXNBK`, INSYNC.
4. `certbot --nginx -d schaufwerks.com -d www.schaufwerks.com --redirect` → Let's Encrypt
   cert valid **→ 2027-01-13**, auto-renew scheduled, HTTP→HTTPS 301.

**Verified live (public internet, HTTPS):** Home, Shop, About, Contact all 200; theme CSS
+ product/background images load with correct content types; www works; HTTP redirects.

**NOT recovered (acceptable — render-only goal):** cart/checkout + individual product
pages (`/store/pN/...`) — Weebly dynamic commerce, never captured, not static-recoverable.
Blog. **Follow-up:** real e-commerce rebuild WITH wife (WooCommerce rec.).

### 5.5 Known cleanups deferred to cutover
- bradschauf.com SPF still contains `+ip4:50.87.221.44` (old Bluehost IP) — update
  when the server IP changes at cutover.
- theschaufs.com / schauf.org are "park now, build a site later" — apex + www point
  at the server; real content comes in a later phase.

### 5.6 Next step — registrar nameserver flip (GO/NO-GO, per domain)

For each domain, at the **Bluehost registrar / domain manager**, change the
nameservers from `ns1/ns2.bluehost.com` to the four Route 53 NS listed in §5.1.
Recommended order: start with one low-traffic domain (e.g. `wekenb.org`), confirm
it resolves via Route 53 for ~1 hour, then do the ProtonMail domains carefully
(watch mail), then the rest. Because records are identical, no outage is expected.
This step is done at the Bluehost control panel (or via Route 53 Domains once
registration is transferred in Phase 2) — awaiting Brad's go-ahead.

### 5.7 Pre-decommission audit detail (2026-10-15)

Full read-only diff of old Bluehost box (`theschau@50.87.221.44`) against schauf-server
`/var/www/*/public` and S3, triggered by Brad disabling Bluehost auto-renew. Method:
`find -type f | wc -l` + byte totals per docroot, both sides; `comm` on file lists for
any dir where counts differed.

**Content gaps found + fixed** (original migration rsync skipped these):

| File | Size | Why missed | Action |
|---|---|---|---|
| `bradschauf/Kayla/Kayla-Marie-Wilson-2020.mp4` | 4.7 GB | large-file skip | → docroot (www-data 644) + S3 `_recovered-originals/Kayla/`. HTTPS 206 range OK. |
| `bradschauf/gigi/pictures/*.tiff` + `photo2.TIF` (9 files) | ~21 MB | `.tiff/.TIF` not transferred | → docroot + S3. (JPG versions already present → site never broke.) |

Junk deltas deliberately NOT copied: `.DS_Store`, `kayla-laugh.ovw`, `Thumbs.db`,
Apache `.htaccess`/`.htaccessold`, stale `.well-known/acme-challenge/*`, `*.bak`.

**wekenb.org (`public_html/wekenborg/`)** — 5398 files / 117,094,144 B. Previously
EXCLUDED (Brad: not serving, don't move). Brad asked for a safety copy "just in case":
pulled to local `migration-data/staging-gap-recovery/wekenborg/` + S3
`bradschauf-media/_recovered-originals/wekenborg-wekenb.org/` (5398 objects, exact byte
match). NOT rehosted — still dropped, just preserved. (One dangling symlink `php.ini`
→ nonexistent `/home1/...` not uploaded; config only, not content.)

**DB dumps** — `~/dbdumps_migration/*.sql` (6 files, Oct 3 snapshots: bradschauf,
gladdenwatch, indecisionranch, nathanschauf, shelbieschauf, shelbiestevenson) → S3
`bradschauf-media/_db-backups-bluehost-20261003/` + local. These are the authoritative
WP/PHP DB backups; weren't off Bluehost before. (catholicfunctions DB dump
`~/migration/theschau_cathfunc.sql` is root-owned → unreadable as theschau; it's the
separate catholicfunctions project, covered by its own `catholicfunctions-db-backups`
S3 bucket.)

**videos/** — re-verified: Bluehost `bradschauf/videos` = 76,957,556,466 B / 98 files;
S3 `bradschauf-media/videos/` = 76,957,535,986 B / 98 objects. Match (diff = du block
overhead).

**Cron killed** — Bluehost crontab had one entry (catholicfunctions_app Laravel
`schedule:run` every minute). `crontab -r` removed it (now empty). Backed up to
`migration-data/staging-gap-recovery/crontab-backup-20261015.txt`. catholicfunctions
runs on AWS; the old-box scheduler was redundant.

**Mail** — intentionally NOT backed up (Brad's standing decision; ProtonMail is live
mail, cPanel boxes unused).

**Conclusion:** everything needed is on AWS (server docroots + S3). Bluehost shared
hosting can lapse / be cancelled with no data loss. `staging-gap-recovery/` is gitignored
(large binaries; S3 is the durable copy).

---

## 6. Phase 2 — Domain registration transfers to Route 53 Domains

**Approach:** transfers are driven by `migration-data/transfer-domain.sh` (one
domain) and tracked by `migration-data/check-transfers.sh`. The transfer sets the
domain's nameservers to its Phase 1 Route 53 zone, so the DNS flip happens
automatically on completion — no separate manual nameserver change. Free WHOIS
privacy is enabled on every transfer (fixes the 3 currently-exposed domains:
shelbiestevenson.com, lindaschauf.com, sadff.com).

**Registrant contact** (all domains): Brad Schauf, Marana AZ 85653,
brad@theschaufs.com — stored in gitignored `migration-data/contact.json`.

**Per-domain manual steps at Bluehost (cannot be scripted):**
1. Unlock domain (remove `clientTransferProhibited`).
2. Disable domain privacy if it blocks the auth code / admin email.
3. Get the EPP/auth code; paste into `migration-data/secrets/<domain>.auth`.
Then run `./transfer-domain.sh <domain>`. Approve the AWS + Bluehost emails sent
to brad@theschaufs.com. Completion takes a few hours up to ~7 days.

**Note:** every in-scope domain was `clientTransferProhibited` (locked) at capture
time — each needs the unlock step before its transfer.

### 6.1 Transfer status

| Domain | Submitted | Operation ID | Status |
|---|---|---|---|
| trialoftheshroud.com (PILOT) | 2026-10-03 | 9ee264d1-… | IN_PROGRESS |
| 2ndaob.com | 2026-10-03 | f6f77f26-… | IN_PROGRESS |
| bradschauf.com | 2026-10-03 | 81d3763a-… | IN_PROGRESS |
| flightoftheshroud.com | 2026-10-03 | 77f51c64-… | IN_PROGRESS |
| gladdenwatch.com | 2026-10-03 | 897e0b33-… | IN_PROGRESS |
| indecisionranch.com | 2026-10-03 | 7e363106-… | IN_PROGRESS |
| jimnewmann.com | 2026-10-03 | 66f0c2ff-… | IN_PROGRESS |
| nathanschauf.com | 2026-10-03 | d7417adf-… | IN_PROGRESS |
| schauf.org | 2026-10-03 | 6cc20bff-… | IN_PROGRESS |
| schaufs.com | 2026-10-03 | df54a769-… | IN_PROGRESS |
| schaufwerks.com | 2026-10-03 | 63b934d5-… | IN_PROGRESS |
| shelbieschauf.com | 2026-10-03 | 276bcbeb-… | IN_PROGRESS |
| shelbiestevenson.com | 2026-10-03 | 1e627560-… | IN_PROGRESS |
| theschaufs.com | 2026-10-03 | ed8faa1c-… | IN_PROGRESS |
| wekenb.org | 2026-10-03 | 1138726b-… | IN_PROGRESS |
| lindaschauf.com | 2026-10-03 | c9c3f524-… | IN_PROGRESS (resubmitted w/ fresh EPP) |
| sadff.com | 2026-10-03 | f99449c2-… | IN_PROGRESS (resubmitted w/ fresh EPP) |
| lilsproutdoodles.com | — | — | HELD (Brad's decision; auth stashed .HOLD) |

**17 IN_PROGRESS**, 1 held. The initial lindaschauf/sadff failures (stale EPP
codes, regenerated by Bluehost when lock/privacy changed) were fixed by pulling
fresh codes and resubmitting; no charge was incurred for the failed attempts.

**Note on batch runner:** submitting 16 in one loop exceeded the 120s command
timeout mid-run; re-running is safe (it skips any domain with an existing `.op`).
Consider submitting in smaller groups or raising the timeout for the full batch.

**Next:** approve AWS + Bluehost transfer emails at brad@theschaufs.com; completion
in hours–7 days. Poll with `./check-transfers.sh`.
