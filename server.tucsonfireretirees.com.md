# tucsonfireretirees.com — Site & Hosting Notes

**Status:** LIVE in production (launched ~Nov 2026).
**Separate project** from the personal Bluehost→AWS migration. Its working docs live in the
app repo `~/GitHub/TucsonFireRetirees` (`deploy/INFRASTRUCTURE-MAP.md` is authoritative;
`AGENTS.md` is the dev/agent guide). This file is just the steering pointer.

## What it is

Event-ticketing + org platform for the **Tucson Fire Retirees Association (TFRA)** — a brand-new
retiree association. Laravel 13 / Livewire 4 / Tailwind 4, single-org, multi-event. Online sales
are event tickets only (merch + 50/50 raffle are in-person, off-platform). Built reusing patterns
from the `catholicfunctions` app (de-tenanted).

## Where it runs

- **Co-hosted as a THIRD nginx vhost on the shared CF Lightsail box** `catholic-functions-med`
  (`44.224.234.4`, us-west-2a, Ubuntu 22.04, nginx + PHP-FPM 8.3 + MariaDB), alongside
  `catholicfunctions.com` and `flockfunctions.com`. The other two sites were not disturbed. No
  new server cost.
- App dir `/var/www/tucsonfireretirees`; DB `tucsonfireretirees` (user `tucsonfireretirees`,
  password in server `.env` only); own nginx vhost + Let's Encrypt cert.
- **No staging** — deploys go straight to prod via `./deploy.sh` (from the repo root, must be on
  `main`; builds Vite assets locally because Node isn't on the box).

## Access

- SSH: `ssh -i ~/.ssh/aws-566105881027.pem deploy@44.224.234.4` (or `ubuntu@` for sudo) — same
  box/key as catholicfunctions / flockfunctions (`~/server-cf.sh`, `~/server-ff.sh`).
- AWS acct `566105881027`, us-west-2. Route 53 zone `Z0517809DU71TBHJS09V`. Registrar: Amazon
  Registrar (Route 53 Domains).

## Services

- **Email: Postmark** for transactional mail (dedicated "Tucson Fire Retirees" server on the
  reused CF Postmark account). Chosen because Amazon SES junked iCloud on this cold domain;
  Postmark inboxed Gmail + ProtonMail + iCloud. SES (us-west-2, production access, DKIM/SPF/DMARC
  + custom MAIL FROM `mail.tucsonfireretirees.com`, scoped IAM user `tfr-ses-mailer`) is fully
  verified and retained for possible future bulk sending, but is NOT the transactional path.
  From address: `no-reply@tucsonfireretirees.com`.
- **Payments: Square** is the primary/launch gateway (the org already has Square); Stripe is kept
  in code as a secondary option. **Square is in SANDBOX** until prod credentials are wired.

## First admins

`brad@theschaufs.com`, `linda@theschaufs.com`.

## Mailboxes (ProtonMail)

Custom domain added Nov 2026 (same pattern as the other Proton domains). Route 53 records: MX
`mail.protonmail.ch`/`mailsec.protonmail.ch`, SPF `v=spf1 include:_spf.protonmail.ch ~all`, DKIM
CNAMEs `protonmail`, `protonmail2`, `protonmail3` `._domainkey`, plus the verification TXT. App mail
still goes through Postmark/SES. Next: confirm Proton tabs are green, create admin@ and no-reply@,
then DMARC rua + quarantine.

## Open items (before/after go-live)

- Square credentials are now entered in the app (Org Settings → Square payments). Rotate the
  sandbox token, enter **production** credentials, and decide which Square account event money lands
  in (SchaufWerks, LLC vs. a new TFRA account).
- Repoint the DMARC `rua` to a monitored mailbox if aggregate reports are wanted.
- (Full backlog + the in-flight day-of card-payment fix are tracked in the app repo, not here.)
