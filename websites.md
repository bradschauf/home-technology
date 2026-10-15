# Personal Websites — Catalog & Migration Record

Catalog of all personal websites migrated off Bluehost shared hosting
(`box2232.bluehost.com`, `theschau` account) onto **schauf-server** (AWS Lightsail,
`44.231.156.226`). Companion to `bluehost-personal-migration.md` (the migration
process) and `server.schauf-server.md` (the server).

- **New server:** schauf-server — `44.231.156.226` — Ubuntu 22.04, NGINX + PHP 8.3 + MariaDB
- **Docroot pattern:** `/var/www/<domain>/public`
- **DNS:** Route 53 (AWS acct 566105881027); registrations transferred to Route 53 Domains
- **Old server IP (pre-cutover):** `50.87.221.44` (Bluehost)
- **Status date:** 2026-10-04 (pre-cutover; DNS A records still point at Bluehost until Phase 6)

Legend: ✅ migrated & verified on schauf-server · ⏳ pending · ⚠️ needs follow-up · ⛔ excluded

**Verification note (2026-10-04):** all sites tested on schauf-server via
`curl -H "Host: <domain>"` against `http://127.0.0.1/`. All return 200 (or expected
301). The `default.html` meta-refresh homepages for shelbieschauf/shelbiestevenson
required an explicit `location = /` → `default.html` in NGINX (they were 403'ing on a
bare directory-index request). bradschauf.com root 403s until its homepage is deployed
from its GitHub repo (only `/blog` is present so far) — expected.

---

## Summary table

| Domain | Type | Docroot on schauf-server | Database | Repo | Mail | Status |
|---|---|---|---|---|---|---|
| indecisionranch.com | WordPress | /var/www/indecisionranch.com/public | theschau_452 | no | dropped | ✅ |
| nathanschauf.com | Static + WP /blog | /var/www/nathanschauf.com/public (+ /blog) | theschau_ss_dbname24e | no | dropped | ✅ |
| shelbieschauf.com | Static + WP /blog | /var/www/shelbieschauf.com/public (+ /blog) | theschau_a16 | no | dropped | ✅ |
| shelbiestevenson.com | Static + WP /blog | /var/www/shelbiestevenson.com/public (+ /blog) | theschau_ss_dbname096 | no | dropped | ✅ |
| bradschauf.com | Static home + WP /blog + S3 media | /var/www/bradschauf.com/public (+ /blog) | theschau_ss_dbnamea75 | yes (home) | ProtonMail | ⏳ home from repo; media to S3 |
| gladdenwatch.com | PHP + MySQL | /var/www/gladdenwatch.com/public | theschau_gladdenwatch | yes | dropped | ✅ ⚠️ repo/deploy + API-key rotation |
| jimnewmann.com | Static | /var/www/jimnewmann.com/public | — | yes | dropped | ✅ ⚠️ repo/deploy |
| flightoftheshroud.com | Static | /var/www/flightoftheshroud.com/public | — | yes | dropped | ✅ ⚠️ repo/deploy |
| trialoftheshroud.com | Redirect | (nginx 301 → flightoftheshroud.com) | — | no | — | ✅ |
| 2ndaob.com | Static | /var/www/2ndaob.com/public | — | no | dropped | ✅ |
| lilsproutdoodles.com | Static | /var/www/lilsproutdoodles.com/public | — | **yes (new)** | dropped | ✅ |
| lindaschauf.com | Blank placeholder | /var/www/lindaschauf.com/public | — | no | dropped | ✅ (never a real site) |
| schaufwerks.com | Static render (ex-Weebly) | /var/www/schaufwerks.com/public | — | **yes** | ProtonMail | ✅ renders on AWS; real store rebuild TODO (wife's site) |
| theschaufs.com | Park (placeholder) | /var/www/theschaufs.com/public | — | no | ProtonMail | ✅ "coming soon" page; build later |
| schauf.org | Park (placeholder) | /var/www/schauf.org/public | — | no | dropped (was Google) | ✅ "coming soon" page; build later |
| sadff.com | Squarespace (external) | n/a — stays on Squarespace | — | no | — | ⛔ hand off to new owner later |
| wekenb.org | WordPress (dead) | not migrated | n/a | no | dropped | ⛔ 403, excluded |

Out of scope entirely (separate infrastructure): catholicfunctions.com,
flockfunctions.com, staging.catholicfunctions.com (see migration doc §5.3a–b).

---

## Per-site details

### indecisionranch.com ✅ WordPress
- Docroot: `/var/www/indecisionranch.com/public` (WP at root).
- DB: `theschau_452` (user `theschau_452`, prefix `452_`, 21 tables, 3.2 MB).
- WP siteurl/home: `https://indecisionranch.com` (correct; 301→https until cert).
- Mail: dropped (was cPanel). Repo: none.

### nathanschauf.com ✅ Static + WordPress blog
- Docroot: `/var/www/nathanschauf.com/public`; static homepage + WP under `/blog`.
- DB: `theschau_ss_dbname24e` (user `theschau_ss_d24e`, prefix `wp_qeoj_`, 24 tables).
- Blog title: "Nathan Schauf — Coming Soon". Mail: dropped. Repo: none.

### shelbieschauf.com ✅ Static + WordPress blog
- Docroot: `/var/www/shelbieschauf.com/public` (incl. `engagement/`) + WP `/blog`.
- DB: `theschau_a16` (user `theschau_a16`, prefix `a16_`, 20 tables).
- Blog title: "Sheblie Schauf Blog". Mail: dropped. Repo: none.
- Homepage is `default.html` (a meta-refresh redirect page). NGINX `location = /`
  serves it explicitly.

### shelbiestevenson.com ✅ Static + WordPress blog
- Docroot: `/var/www/shelbiestevenson.com/public` + WP `/blog`.
- DB: `theschau_ss_dbname096` (user `theschau_ss_d096`, prefix `wp_dmbg_`, 20 tables).
- Blog title: "Shelbie Stevenson — Daughter. Sailor." Mail: dropped. Repo: none.
- Homepage is `default.html` (meta-refresh redirect, 120s). NGINX `location = /`
  serves it explicitly.

### bradschauf.com ✅ Three-part site — all assembled
- **Homepage:** ✅ deployed from the **GitHub repo** (`~/GitHub/bradschauf.com`,
  `site/` dir). Title "Brad Schauf", HTTP 200. Deployed via rsync `site/` →
  `/var/www/bradschauf.com/public/` (excluding `blog`, no --delete). NOTE: repo's
  `deploy.sh` still targets Bluehost — update it to schauf-server post-cutover.
- **Blog:** ✅ WordPress under `/blog`, DB `theschau_ss_dbnamea75` (user
  `theschau_ss_da75`, prefix `wp_zdpe_`, 17 tables). Title "Schauf Blog", HTTP 200.
- **Media (`/videos`, ~72 GB):** ✅ S3 (`bradschauf-media`) + CloudFront
  (`d1xmnyfjt1ssl3.cloudfront.net`). NGINX `location /videos/` proxies to CloudFront,
  so `bradschauf.com/videos/...` URLs are preserved. Verified HTTP 206 (ranged video).
- Large media NOT in the repo (`.gitignore` excludes `*.mp4` + big images — they live
  in S3). Mail: ProtonMail (preserved). Repo: yes (homepage).

### gladdenwatch.com ✅ ⚠️ PHP app + MySQL
- Docroot: `/var/www/gladdenwatch.com/public`. "GladdenWatch — Gladden Farms
  Neighborhood Watch, Marana AZ."
- DB: `theschau_gladdenwatch` (user `theschau_gladdenwatchplatform`, 9 tables w/ data
  — audit_log, users, members, incidents, neighborhoods).
- NGINX guards block config/setup/migrate/backup PHP files from web access.
- ⚠️ **Follow-up:** repo-managed (GitHub) — reconcile code with repo + update deploy
  script. **Rotate Google Maps + Geocoding API keys** (surfaced during migration).
- Mail: dropped. Repo: yes.

### jimnewmann.com ✅ ⚠️ Static
- Docroot: `/var/www/jimnewmann.com/public`. "Jim Newmann's Story." 7 files.
- ⚠️ Repo-managed — update deploy script to target schauf-server.
- Mail: dropped (had cPanel). Repo: yes.

### flightoftheshroud.com ✅ ⚠️ Static
- Docroot: `/var/www/flightoftheshroud.com/public`. "Flight of the Shroud — Images." 55 MB.
- ⚠️ Repo-managed — update deploy script. Mail: dropped. Repo: yes.

### trialoftheshroud.com ✅ Redirect
- No content; NGINX 301 → `https://flightoftheshroud.com$request_uri` (matches
  Bluehost behavior). Registration transferred; no docroot.

### 2ndaob.com ✅ Static
- Docroot: `/var/www/2ndaob.com/public`. "Second Amendment On Board." 12 files.
- Mail: dropped. Repo: none.

### lilsproutdoodles.com ✅ Static
- Docroot: `/var/www/lilsproutdoodles.com/public`. "Lil Sprout Doodles" (dog/doodle
  site — photos + video). 21 files, 11 MB. HTTP 200, verified.
- Previously held from the transfer batch; now fully in scope — files migrated,
  NGINX block live, domain transfer submitted 2026-10-04 (op d1ec231f...).
- **Repo:** `github.com/bradschauf/lilsproutdoodles.com` (private, created 2026-10-04).
  `deploy.sh` already targets schauf-server (first repo to do so — model for updating
  the others). Media kept in-repo (small, 11 MB). Mail: dropped.

### lindaschauf.com ✅ Placeholder
- Never a real site (only an empty `default.html` on Bluehost). Blank `index.html`
  placeholder added → 200. Mail: dropped. Repo: none.

### schaufwerks.com ✅ Static render on AWS (ex-Weebly commerce) — rebuild TODO
- **Linda's (wife's) site.** Was a LIVE Weebly e-commerce store; **Bluehost broke it**
  after the registrar transfer (dropped the cert, served a Weebly "page cannot be
  displayed" error). The store was dead on Bluehost with no fix available to us.
- **Resolved 2026-10-15:** recovered a static render onto schauf-server and flipped it
  to AWS over HTTPS. Full write-up: `bluehost-personal-migration.md` §5.4b.
  - Pages live: Home + Shop (recovered from Wayback Machine 2023 captures) + About +
    Contact (from the static export), with original Weebly theme CSS + product photos.
  - A record flipped to `44.231.156.226`; Let's Encrypt cert (apex + www, → 2027-01-13);
    HTTP→HTTPS 301. ProtonMail records untouched.
  - Content preserved 3 ways: local `migration-data/staging-schaufwerks/` (gitignored),
    S3 `s3://schaufwerks-archive/schaufwerks-site/`, and the server docroot.
- **How the OLD store worked (why it's render-only now):** Weebly commerce was
  **dynamic** — `.htaccess` routed `/ajax/*` + `index.html` through Weebly's
  **`w_api/Handler.php`** API handler; product/cart/checkout data lived in Weebly's
  backend, NOT in the exported files (`SHOP/` was empty). So cart/checkout + individual
  product pages (`/store/pN/...`) are NOT recoverable as static. The current site
  renders the storefront content but does not take orders.
- ⚠️ **Still TODO — real store rebuild** (migrate products + payment config; NOT a
  static file port). Open-source options considered:
  - **WooCommerce (WordPress plugin) — RECOMMENDED.** Fits the existing schauf-server
    LAMP-ish stack (PHP + MariaDB), familiar (5 WP sites already there), self-hosted,
    no monthly platform fee, Stripe/PayPal/Square plug in. Best fit for a small store.
  - Medusa (Node, "open-source Shopify") — modern but a bigger lift (Node + separate
    storefront). Overkill here.
  - Saleor (Python/GraphQL) — enterprise-grade, too heavy.
  - PrestaShop / OpenCart (PHP self-hosted carts) — viable, smaller community than Woo.
  - Products/images/pricing are NOT in the Bluehost export (SHOP/ empty; data lives in
    Weebly's backend) — catalog must be re-entered/exported from Weebly regardless of
    platform. Payments always go through a processor (Stripe/PayPal/Square) — not OSS
    but free to integrate, per-transaction fees.
  - This is a project to plan WITH Linda (catalog + payment decisions).
- Mail: ProtonMail (preserved). Repo: none.

### theschaufs.com ✅ Park (placeholder)
- Returned 403 on Bluehost (base site never worked). Now a "coming soon" placeholder
  at `/var/www/theschaufs.com/public` (200) with an NGINX block, ready for a future
  build. Mail: **ProtonMail** (main family mail — preserved).

### schauf.org ✅ Park (placeholder)
- Returned 403 on Bluehost. Now a "coming soon" placeholder at
  `/var/www/schauf.org/public` (200). Google Workspace mail dropped (no longer used).
  Ready for a future family site.

### sadff.com ⛔ External (Squarespace)
- Hosted on Squarespace (not Bluehost). Registration transferred into Brad's custody
  so it survives Bluehost cancellation; DNS records (Squarespace A/CNAME) preserved
  in Route 53. **TODO: hand off to eventual owner.**

### wekenb.org ⛔ Website excluded (domain still transferred)
- WordPress at `wekenborg/` returning 403 (not serving). Brad does not want the
  **website** moved — it is NOT migrated to schauf-server and has no NGINX block.
- The **domain registration** IS being transferred into Brad's AWS account (Brad
  still owns it); its Route 53 zone exists. So "excluded" means the site, not the
  domain. At cutover, decide what wekenb.org should resolve to (currently its A
  record still → Bluehost `50.87.221.44`; with no site on schauf-server it would
  404/placeholder — may want a redirect or a park page).

---

## Mail summary
- **ProtonMail (preserved):** theschaufs.com, schaufs.com, bradschauf.com, schaufwerks.com.
- **Dropped (all other domains):** old cPanel mailboxes abandoned; schauf.org's Google
  Workspace dropped. No MX recreated for these in Route 53.

## Outstanding follow-ups
1. bradschauf.com media → S3 + CloudFront (72 GB) — in progress.
2. TLS certs (Let's Encrypt) for all domains — at/after cutover.
3. Cutover: flip Route 53 A records 50.87.221.44 → 44.231.156.226, per site.
4. Repo-managed deploy scripts (jimnewmann, gladdenwatch, flightoftheshroud,
   bradschauf) → re-point at schauf-server; walkthrough with Brad.
5. Rotate gladdenwatch Google API keys.
6. Rebuild schaufwerks.com.
7. Build out theschaufs.com and schauf.org.
8. Hand off sadff.com.
