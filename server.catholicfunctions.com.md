# CatholicFunctions.com — VPS Server Documentation

**Server:** `server.catholicfunctions.com`
**Provider:** Bluehost VPS
**OS:** CentOS/RHEL
**IP:** 129.121.119.87

---

## Table of Contents

1. [Server Overview](#1-server-overview)
2. [User Setup & SSH Access](#2-user-setup--ssh-access)
3. [Firewall Configuration](#3-firewall-configuration) *(to document)*
4. [Web Server Setup](#4-web-server-setup) *(to document)*
5. [Domain & DNS Configuration](#5-domain--dns-configuration) *(to document)*
6. [SSL/TLS Certificates](#6-ssltls-certificates) *(to document)*
7. [Database Setup](#7-database-setup) *(to document)*
8. [Application Deployment](#8-application-deployment) *(to document)*
9. [Backups](#9-backups) *(to document)*
10. [Monitoring & Logs](#10-monitoring--logs) *(to document)*
11. [Cron Jobs & Automation](#11-cron-jobs--automation) *(to document)*
12. [Troubleshooting](#12-troubleshooting) *(to document)*

---

## 1. Server Overview

| Field | Value |
|---|---|
| Hostname | `server.catholicfunctions.com` |
| IP Address | `129.121.119.87` |
| Provider | Bluehost VPS |
| OS | CentOS/RHEL |
| Root User | `root` |
| Admin User | `brad` |

---

## 2. User Setup & SSH Access

Guide for creating a non-root sudo admin user with SSH key authentication.

### 2.1 SSH in as Root

```bash
ssh root@129.121.119.87
```

### 2.2 Create the New User

```bash
adduser brad
```

You'll be prompted to set a password and optional profile info.

### 2.3 Grant Admin (sudo) Privileges

On CentOS/RHEL, the admin group is `wheel` (not `sudo` as on Debian/Ubuntu):

```bash
usermod -aG wheel brad
```

Verify the group was assigned:

```bash
groups brad
# Expected output: brad : brad wheel
```

### 2.4 SSH Keypair

Reused an existing keypair from this Mac rather than generating a new one:

- **Public key:** `/Users/brad/.ssh/schauf.pub` — copied to the server
- **Private key:** `/Users/brad/.ssh/schauf.priv` — used for authentication (keep secret, never share)

To generate a fresh keypair in the future:

```bash
ssh-keygen -t ed25519 -C "bluehost-automation" -f ~/.ssh/bluehost_admin
```

### 2.5 Add the Public Key to the Server

Back on the server (logged in as root):

```bash
mkdir -p /home/brad/.ssh
chmod 700 /home/brad/.ssh
nano /home/brad/.ssh/authorized_keys
```

Paste the contents of `~/.ssh/bluehost_admin.pub` from your local machine, then save (`Ctrl+O`, `Ctrl+X`).

Set correct permissions:

```bash
chmod 600 /home/brad/.ssh/authorized_keys
chown -R brad:brad /home/brad/.ssh
```

### 2.6 Test the New User (in a new terminal — keep root session open)

```bash
ssh -i ~/.ssh/bluehost_admin brad@129.121.119.87
```

Verify sudo access:

```bash
sudo whoami
# Expected output: root
```

### 2.7 (Recommended — Not Done) Harden SSH

Not configured yet. Root SSH login was left enabled intentionally since the root password is long and random. If hardening in the future, edit `/etc/ssh/sshd_config` and set:

```
PermitRootLogin no
PasswordAuthentication no
```

Restart SSH to apply:

```bash
sudo systemctl restart sshd
```

### 2.8 SSH Config Shortcut for Automation

Add to `~/.ssh/config` on your local machine:

```
Host bluehost-vps
    HostName 129.121.119.87
    User brad
    IdentityFile /Users/brad/.ssh/schauf.priv
```

Then connect with just:

```bash
ssh bluehost-vps
ssh bluehost-vps "your-command-here"
```

> **Note:** CentOS/RHEL uses the `wheel` group for sudo access; Debian/Ubuntu use `sudo`. Always test new user login before disabling root SSH to avoid lockout.

---

## 3. Firewall Configuration

*(to document)*

Suggested topics: `firewalld` setup, open ports (80, 443, 22), blocking unused ports.

---

## 4. Web Server Setup

*(to document)*

Suggested topics: nginx or Apache install & config, virtual hosts, serving the app.

---

## 5. Domain & DNS Configuration

*(to document)*

Suggested topics: DNS records pointing to `129.121.119.87`, nameserver settings, propagation check.

---

## 6. SSL/TLS Certificates

*(to document)*

Suggested topics: Let's Encrypt / Certbot install, auto-renewal cron, HTTPS redirect.

---

## 7. Database Setup

*(to document)*

Suggested topics: MySQL/PostgreSQL install, creating app DB and user, securing root DB access.

---

## 8. Application Deployment

*(to document)*

Suggested topics: deploying the app, environment variables, process manager (PM2 or systemd), deploy scripts.

---

## 9. Backups

*(to document)*

Suggested topics: what gets backed up, backup schedule, where backups are stored, how to restore.

---

## 10. Monitoring & Logs

*(to document)*

Suggested topics: log locations (`/var/log`), checking service status, uptime monitoring, disk/memory alerts.

---

## 11. Cron Jobs & Automation

*(to document)*

Suggested topics: crontab entries, automation scripts, SSH key usage for remote tasks.

---

## 12. Troubleshooting

*(to document)*

Suggested topics: SSH issues, service won't start, port conflicts, common error messages and fixes.