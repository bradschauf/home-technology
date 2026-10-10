# AWS Lightsail Right-Sizing Plan — catholicfunctions / flock

Scoped optimization to cut the oversized catholicfunctions/flock Lightsail spend.
**Separate from the personal Bluehost migration** — this is the catholicfunctions
project's production infrastructure (hands-off during the personal migration). This
doc scopes it; execution should be a deliberate, project-owned task with its own
SSH access and verification.

Corrected pricing note: earlier estimates misread the tiers. Actual (us-west-2):
`xlarge_3_0` = **$84/mo** (not $160); `medium_3_0` = **$24/mo** (not $40).

---

## 1. Current state (measured 2026-10-04)

| Instance | Bundle | Specs | $/mo | CPU avg (7d) | CPU peak (7d) |
|---|---|---|---|---|---|
| catholic-functions-xl | xlarge_3_0 | 16 GB / 4 vCPU / 320 GB | $84 | **0.1%** | 4–23% |
| flock-functions | medium_3_0 | 4 GB / 2 vCPU / 80 GB | $24 | **1.0%** | 5–33% |
| | | | **$108** | | |

Both are heavily underutilized on CPU. `catholic-functions-xl` was upsized for an
event and no longer needs that capacity (0.1% avg, 23% peak on 4 vCPU = ~idle).

**14-day CPU detail (catholic-functions-xl), confirms oversizing:**
| Date | avg | peak | note |
|---|---|---|---|
| 2026-09-25 | 0.2% | 1.7% | |
| 2026-09-26 | 0.1% | 4.0% | resize-snapshot day; near-idle |
| 2026-09-27 | 0.1% | 3.9% | |
| 2026-09-28 | 0.1% | **23.4%** | highest in window — brief spike |
| 2026-09-29 | 0.1% | 9.3% | |
| 2026-09-30 | 0.1% | **22.9%** | |
| 2026-10-01 | 0.1% | 7.4% | |
| 2026-10-02 | 0.1% | 6.1% | |
| 2026-10-03 | 0.1% | 5.9% | |

Max observed peak ≈ **23% on 4 vCPU** = ~0.9 vCPU-equivalent, and only briefly
(avg stays 0.1%). On a 2-vCPU `medium` that same peak ≈ **46%** — comfortable headroom.
Translating to a shared box: catholic (~0.1% avg) + flock (~1.0% avg) + staging
(near-zero) combined is trivial CPU load. **CPU is NOT the constraint for consolidation.**

**Open data gap — RAM:** Lightsail exposes no memory metric, and SSH with the
available key (`schauf-server.pem`) was denied on both (they use `flock-functions-key`,
possibly a non-`ubuntu` user). **RAM is the one real risk** for stacking three apps
(2 Laravel + flock) + their MySQL on a 4 GB medium. Must measure actual RAM with the
project's SSH key before committing. If 4 GB is tight, `large_3_0` (8 GB, $44) still
beats the current $108 and holds everything comfortably.

---

## 2. Target plan (Brad's intent — CONSOLIDATE TO ONE BOX)

Downsize catholic and **co-host three apps on the single resized instance**:
1. **catholicfunctions.com production** (already there)
2. **staging.catholicfunctions.com** (rehomed off the dying Bluehost shared box —
   see bluehost-personal-migration.md §5.3b; this resolves that gate)
3. **flockfunctions.com** (moved over from its own instance)

Then **delete the separate `flock-functions` instance entirely.**

### Bundle tiers (us-west-2, non-Windows, IPv4)
| Bundle | RAM | vCPU | Disk | $/mo |
|---|---|---|---|---|
| nano_3_0 | 0.5 GB | 2 | 20 GB | $5 |
| micro_3_0 | 1 GB | 2 | 40 GB | $7 |
| small_3_0 | 2 GB | 2 | 60 GB | $12 |
| medium_3_0 | 4 GB | 2 | 80 GB | $24 |
| large_3_0 | 8 GB | 2 | 160 GB | $44 |

### ⚠️ CORRECTED PLAN (Brad, 2026-10-04): xlarge is FAILOVER → promote to PROD, retire VPS, THEN right-size
`catholic-functions-xl` is a **warm failover**, not current prod. Catholic prod runs
on the **Bluehost VPS** (`129.121.119.87`). The 0.1% Lightsail CPU just means the
failover box sits idle — meaningless for sizing until it carries prod traffic.

Correct sequence (full detail in the `catholicfunctions` repo →
`VPS-RETIREMENT-AND-RIGHTSIZING.md`):
1. **Promote** catholic-functions-xl to production (cut over from the Bluehost VPS).
2. **Retire the Bluehost VPS** (this project's half of "fully off Bluehost").
3. **Fold in** staging.catholicfunctions.com + flockfunctions.com; **delete** the
   flock-functions instance.
4. **THEN right-size** the instance down from xlarge based on REAL measured prod +
   event load (not the current idle metrics). `large_3_0` (8 GB, $44) is a plausible
   landing spot but must be validated against real traffic — this app warranted
   failover capacity for the gala, so don't undersize blindly.

**Do NOT resize before promotion.** Sizing an idle failover box tells you nothing.

**Savings:** end state ~1 Lightsail instance (likely $44 large) vs. $108/mo Lightsail
now — saves ~$64/mo — **plus** eliminating the entire Bluehost VPS fee.

**Execution owned by the catholicfunctions project / repo.** This home-tech doc
records the decision + data; the work runs there with its VPS/Lightsail keys and app
knowledge.

---

## 3. Execution approach (Lightsail resize = snapshot → relaunch → swap IP)

Lightsail cannot resize in place and cannot shrink a running instance. Each resize:
1. Pre-flight: check disk usage fits the smaller tier's disk; check RAM headroom.
2. `create-instance-snapshot` of the source (safety net + the resize source).
3. `create-instances-from-snapshot` at the new (smaller) bundle.
4. Verify the app boots and runs on less RAM (load test prod paths; for catholic,
   also stand up staging alongside prod).
5. Move the static IP to the new instance; delete the old one.
6. For catholic: add staging.catholicfunctions.com as a second app (separate NGINX
   server block + DB + .env) and point its DNS at the new instance.

**Instance-count limit:** account caps Lightsail at 3 instances; currently at 3
(schauf-server, catholic-xl, flock). The snapshot→relaunch dance needs a temporary
4th slot. **Request a quota increase to 5** before starting.

**Downtime:** brief per-instance (IP swap). Schedule off-peak; catholic is a live app
and schaufwerks-style "live commerce" caution does not apply, but confirm no event is
imminent.

---

## 4. Decisions / prerequisites before executing
- [ ] Get the project's SSH key (`flock-functions-key` or equivalent) to measure RAM
      and confirm disk usage < target tier disk.
- [ ] Confirm flock target tier (micro $7 vs small $12) from its RAM use.
- [ ] Confirm no catholicfunctions event is imminent (don't downsize right before one).
- [ ] Request Lightsail instance quota bump 3 → 5.
- [ ] Decide prod+staging coexistence details on the medium (DB separation, memory).
- [ ] This also resolves the staging.catholicfunctions.com Bluehost gate.

## 5. Also recorded elsewhere
- `catholic-functions-resize-2026-09-26` 60 GB instance snapshot (~$3/mo) is a
  leftover from the earlier xlarge resize — can be deleted once that resize is
  confirmed settled (project's call).
