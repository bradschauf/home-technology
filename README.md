# home-technology

Documentation and tooling for Brad Schauf's personal technology infrastructure — the
home network, personal servers, websites, and the migration of everything off Bluehost
onto AWS.

## Contents

| Doc | What it covers |
|---|---|
| [home-network.md](home-network.md) | Home network diagram, equipment (Calix fiber router, mesh, switches), IoT devices, DNS (Cloudflare), troubleshooting, and historical configs. |
| [launchd-jobs.md](launchd-jobs.md) | Scheduled `launchd` jobs on Brad's Mac (`com.bradschauf.*`): scripts, schedules, enabled state, and how to manage them. |
| [server.schauf-server.md](server.schauf-server.md) | The personal web server (AWS Lightsail, `44.231.156.226`): specs, SSH access, NGINX/PHP/MariaDB stack, hosted sites, upload-dir notes, backups, cost. |
| [server.catholicfunctions.com.md](server.catholicfunctions.com.md) | Reference doc for the catholicfunctions server (separate project). |
| [websites.md](websites.md) | Catalog of every personal website: type, docroot, database, repo, mail, migration status. |
| [bluehost-personal-migration.md](bluehost-personal-migration.md) | The full Bluehost→AWS migration record + plan. Has a **▶ RESUME HERE** block at the top with current status and remaining work. |
| [aws-cost-breakdown.md](aws-cost-breakdown.md) | AWS account cost breakdown (personal vs. catholicfunctions project). |
| [aws-rightsizing-plan.md](aws-rightsizing-plan.md) | Lightsail right-sizing analysis (mostly catholicfunctions-project; cross-referenced). |
| [scripts/](scripts/) | Version-controlled home for personal utility scripts (check-sites + its config, SSH helpers). One true copy; home-dir symlinks for the interactive ones. See `scripts/README.md`. |
| `migration-data/` | Scripts + DNS data used during the migration (R53 records, transfer/cutover scripts, etc.). Secrets and large staging are gitignored. |

## Current state (2026-10-11)

- **Personal sites + domains:** fully migrated to AWS. All 16 sites live on
  **schauf-server** (Lightsail) over HTTPS; all domains registered at AWS (Route 53
  Domains). bradschauf.com media on S3 + CloudFront.
- **Nothing left on Bluehost.** schaufwerks.com (wife's ex-Weebly store) is now a static
  render on AWS over HTTPS (recovered 2026-10-15); a real e-commerce rebuild is a separate
  follow-up, not a Bluehost blocker. The Bluehost shared-hosting account can now be
  cancelled (push for a prorated refund).
- **catholicfunctions / flockfunctions:** separate project; its Bluehost VPS is cancelled
  and it's consolidated on AWS. Its working docs live in the `catholicfunctions` repo.

See the **▶ RESUME HERE** block in `bluehost-personal-migration.md` for the authoritative,
always-current status and next steps.

## Key access

- **schauf-server (new):** `~/theschaufs.sh` or `~/schaufserver.sh` → `ubuntu@44.231.156.226`
  (key `~/.ssh/schauf-server.pem`). Docroots: `/var/www/<domain>/public`.
- **Old Bluehost shared box (being decommissioned):** `~/old-theschaufs.sh` →
  `theschau@50.87.221.44` (key `~/.ssh/schauf.priv`). Connect by IP; rapid SSH trips cPHulk.
- **AWS:** account `566105881027`, region `us-west-2` (default CLI profile).

## Conventions

- Secrets (SSH keys, auth codes, DB passwords, contact JSON) are **never committed** —
  see `.gitignore`. Large staging/media dirs are gitignored too.
- Each repo-managed site (bradschauf.com, jimnewmann.com, flightoftheshroud, gladdenwatch,
  lilsproutdoodles.com, speedmon, white-rabbit) has its own repo with a `deploy.sh` that
  targets schauf-server.
