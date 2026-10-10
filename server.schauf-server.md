# Schauf Server — Personal Server Documentation

**Instance:** `schauf-server` (AWS Lightsail)
**Provider:** AWS Lightsail — account `566105881027`
**OS:** Ubuntu 22.04 LTS
**Static IP:** `44.231.156.226`
**Region/AZ:** us-west-2 / us-west-2a

This is Brad's new personal server, replacing the old Bluehost shared hosting
(`box2232.bluehost.com`, `theschaufs` account). It hosts all personal websites
migrated off Bluehost. Large media (bradschauf.com videos) lives separately in
S3 + CloudFront, not on this box. See `bluehost-personal-migration.md` for the
full migration record.

---

## Table of Contents

1. [Server Overview](#1-server-overview)
2. [SSH Access](#2-ssh-access)
3. [Firewall Configuration](#3-firewall-configuration)
4. [Web Server Setup](#4-web-server-setup) *(to document in Phase 4)*
5. [Domain & DNS Configuration](#5-domain--dns-configuration)
6. [SSL/TLS Certificates](#6-ssltls-certificates) *(to document in Phase 4)*
7. [Database Setup](#7-database-setup) *(to document in Phase 4)*
8. [Hosted Sites](#8-hosted-sites)
9. [Media Offload (S3 + CloudFront)](#9-media-offload-s3--cloudfront) *(to document in Phase 4)*
10. [Backups & Snapshots](#10-backups--snapshots)
11. [Resizing](#11-resizing)
12. [Cost](#12-cost)

---

## 1. Server Overview

| Field | Value |
|---|---|
| Instance name | `schauf-server` |
| Provider | AWS Lightsail (account `566105881027`) |
| OS | Ubuntu 22.04.5 LTS |
| Bundle | `small_3_0` — 2 GB RAM, 2 vCPU, 60 GB SSD |
| Region / AZ | us-west-2 / us-west-2a |
| Static IP | `44.231.156.226` (Lightsail static IP `schauf-server-ip`) |
| Default user | `ubuntu` |
| SSH key | `schauf-server-key` (private key stored at `~/.ssh/schauf-server.pem`, outside the repo) |
| Blueprint | `ubuntu_22_04` |

### Sizing rationale
Media (72 GB) offloads to S3, so the box only serves ~2.3 GB of sites (6 WordPress
blogs + PHP + static). Disk is not the constraint; RAM is (WordPress + PHP-FPM +
MariaDB). The 2 GB / $12 tier gives comfortable headroom for low-traffic personal
sites. Scale up (not down) is easy via snapshot — see §11.

---

## 2. SSH Access

```bash
# Quick helper (in home dir):
~/schaufserver.sh

# Or directly:
ssh -i ~/.ssh/schauf-server.pem ubuntu@44.231.156.226
```

The private key is PEM (`-----BEGIN RSA PRIVATE KEY-----`), mode 600, stored at
`~/.ssh/schauf-server.pem` — **outside this repo** for safety (never committed).
A convenience launcher lives at `~/schaufserver.sh` (mirrors the old
`~/theschaufs.sh`). The default Lightsail user is `ubuntu` (passwordless sudo).

---

## 3. Firewall Configuration

Lightsail instance firewall (set via `put-instance-public-ports`):

| Port | Protocol | Purpose |
|---|---|---|
| 22 | TCP | SSH |
| 80 | TCP | HTTP (Let's Encrypt + redirect to HTTPS) |
| 443 | TCP | HTTPS |

```bash
aws lightsail put-instance-public-ports --region us-west-2 --instance-name schauf-server \
  --port-infos fromPort=22,toPort=22,protocol=TCP \
               fromPort=80,toPort=80,protocol=TCP \
               fromPort=443,toPort=443,protocol=TCP
```

TODO (hardening, Phase 4): restrict port 22 to Brad's IP, enable `ufw`, enable
unattended-upgrades.

---

## 4. Web Server Setup

*(To document in Phase 4.)* Planned stack: NGINX + PHP 8.3 (FPM) + MariaDB, with
one NGINX server block per site (static, PHP, and WordPress). Certbot for TLS.

---

## 5. Domain & DNS Configuration

DNS is hosted in Route 53 (account `566105881027`) — zones built in Phase 1 of the
migration. At Phase 4 cutover, each site's apex `A` (and `www`) record changes from
the old Bluehost IP `50.87.221.44` to this server's static IP **`44.231.156.226`**.
Until cutover, records still point at Bluehost so nothing changes prematurely.

---

## 6. SSL/TLS Certificates

*(To document in Phase 4.)* Let's Encrypt via certbot (NGINX plugin), one cert per
domain (apex + www), auto-renew via the certbot systemd timer.

---

## 7. Database Setup

*(To document in Phase 4.)* MariaDB server; one database + user per WordPress/PHP
site that needs one. Migrated from the Bluehost MySQL databases.

---

## 8. Hosted Sites

NGINX server blocks live under `/etc/nginx/sites-enabled/`. Each site's docroot is
`/var/www/<domain>/public`. Full per-site detail is in `websites.md`.

Enabled server blocks (14) as of 2026-10-04:
- **WordPress:** indecisionranch.com, nathanschauf.com, shelbieschauf.com,
  shelbiestevenson.com, bradschauf.com (`/blog` only; homepage pending from repo)
- **PHP:** gladdenwatch.com
- **Static:** jimnewmann.com, flightoftheshroud.com, 2ndaob.com
- **Placeholders:** lindaschauf.com (blank), schaufwerks.com (Weebly rebuild TODO),
  theschaufs.com + schauf.org (park "coming soon")
- **Redirect:** trialoftheshroud.com → flightoftheshroud.com

NOT hosted here: bradschauf.com media (S3 `bradschauf-media` + CloudFront
`E2XK5VTX2AB0AM`), sadff.com (Squarespace), catholicfunctions.com /
flockfunctions.com (separate infra). wekenb.org website excluded (domain still owned).

NGINX notes:
- WordPress sites use `try_files $uri $uri/ /index.php?$args` + a `location /blog/`
  for the sub-path installs; `wp-config.php` is denied over HTTP.
- shelbieschauf/shelbiestevenson use `location = / { try_files /default.html ... }`
  because their homepage is a `default.html` meta-refresh page (not index.html).
- gladdenwatch.com NGINX block denies web access to config/setup/migrate/backup PHP.
- TLS not yet issued (DNS still points at Bluehost; certs are a cutover step).

---

## 9. Media Offload (S3 + CloudFront)

*(To document in Phase 4.)* bradschauf.com's ~72 GB video archive → S3 bucket,
fronted by CloudFront, preserving `bradschauf.com/videos/...` URLs. Keeps the web
instance small.

---

## 10. Backups & Snapshots

*(To set up.)* Lightsail supports automatic daily snapshots (enable per instance,
small cost) and manual snapshots. Plan: enable automatic snapshots once sites are
live. Manual snapshot before any risky change:

```bash
aws lightsail create-instance-snapshot --region us-west-2 \
  --instance-name schauf-server --instance-snapshot-name schauf-server-YYYY-MM-DD
```

---

## 11. Resizing

Lightsail cannot resize in place and cannot shrink. To scale **up**: snapshot the
instance, create a larger instance from the snapshot, reattach the static IP, delete
the old one.

```bash
aws lightsail create-instance-snapshot --region us-west-2 --instance-name schauf-server --instance-snapshot-name schauf-server-resize
aws lightsail create-instances-from-snapshot --region us-west-2 --instance-names schauf-server-new --availability-zone us-west-2a --instance-snapshot-name schauf-server-resize --bundle-id medium_3_0
aws lightsail attach-static-ip --region us-west-2 --static-ip-name schauf-server-ip --instance-name schauf-server-new
```

Note: a stopped Lightsail instance still bills at the full bundle price — only
deleting stops the charge.

---

## 12. Cost

| Item | Monthly |
|---|---|
| Instance (`small_3_0`, 2 GB) | $12.00 |
| Static IP (attached) | $0.00 (free while attached to a running instance) |
| S3 storage (~72 GB media) | ~$1.70 |
| CloudFront egress | ~a few $ (traffic-dependent) |
| **Est. steady state** | **~$17/mo** |

Plus one-time ~$250–280 of domain registration transfers (Phase 2), which prepay a
year each.

---

## Provisioning Record

- Created 2026-10-03 in account 566105881027, region us-west-2, AZ us-west-2a.
- To free a Lightsail slot (account capped at 3), the stopped leftover
  `catholic-functions` instance was deleted (snapshot
  `catholic-functions-resize-2026-09-26` retained as backup). Confirmed safe by Brad.
- Launched `schauf-server` (ubuntu_22_04 / small_3_0), key `schauf-server-key`,
  static IP `44.231.156.226`, firewall 22/80/443. SSH verified. Clean OS, no stack
  installed yet.
