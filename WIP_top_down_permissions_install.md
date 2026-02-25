Your instinct is correct, and this is exactly the right way to think about it. Let me break down the permission model first, then the phased setup.

---
# FINAL STRUCTURE:

## What the agent actually needs write access to

```
.openclaw/
 ┣ agents/main/sessions/          ✅ WRITE  — saves conversation logs
 ┣ cron/jobs.json                 ✅ WRITE  — if agent schedules tasks
 ┣ logs/config-audit.jsonl        ✅ APPEND only — audit trail
 ┣ workspace/                     ✅ WRITE  — everything here
 ┃ ┣ MEMORY.md                    ✅ WRITE  — long-term memory
 ┃ ┣ SOUL.md                      ✅ WRITE  — (debatable, see below)
 ┃ ┣ USER.md                      ✅ WRITE  — user profile updates
 ┃ ┣ HEARTBEAT.md                 ✅ WRITE  — proactive task log
 ┃ ┣ .openclaw/workspace-state.json ✅ WRITE — resume state
 ┣ canvas/                        ❌ READ ONLY — static UI
 ┣ completions/                   ❌ READ ONLY — shell scripts
 ┣ identity/device.json           ❌ READ ONLY — device identity
 ┣ devices/                       ❌ READ ONLY — pairing state
 ┣ .env                           ❌ READ ONLY — secrets (agent reads, never writes)
 ┣ openclaw.json                  ❌ READ ONLY — you configure, not the agent
 ┗ openclaw.json.bak*             ❌ READ ONLY
```

[your projects]              ✅ WRITE

---

## Proposed two-user model

```
root / admin user  →  installs openclaw, owns the install directory
openclaw user      →  runs the daemon, restricted writes only
```

---

## Phased setup approach

### Phase 1 — Install (as root or sudo user)
```bash
# Create restricted system user — no login shell, no home dir
useradd --system --no-create-home --shell /usr/sbin/nologin openclaw

# Install binaries (owned by root, not writable by openclaw)
chown -R root:root /opt/openclaw_install
chmod -R 755 /opt/openclaw_install

# Create the data directory with correct ownership
mkdir -p /opt/openclaw_data/.openclaw
chown -R openclaw:openclaw /opt/openclaw_data
```

### Phase 2 — Lock down config files (as root)
```bash
DATA=/opt/openclaw_data/.openclaw

# These dirs are read-only for the openclaw user
chown root:openclaw $DATA/canvas
chown root:openclaw $DATA/completions
chown root:openclaw $DATA/identity
chown root:openclaw $DATA/devices
chown root:openclaw $DATA/.env
chown root:openclaw $DATA/openclaw.json
chmod 640 $DATA/.env          # root:openclaw, group read only
chmod 750 $DATA/canvas $DATA/completions $DATA/identity $DATA/devices

# SOUL.md is read-only for the agent
chown root:openclaw $DATA/workspace/SOUL.md
chmod 440 $DATA/workspace/SOUL.md

# These are writable by the openclaw user
chown -R openclaw:openclaw $DATA/agents
chown -R openclaw:openclaw $DATA/cron
chown -R openclaw:openclaw $DATA/workspace

# Logs: append-only (even the agent can't delete/edit, only append)
chown openclaw:openclaw $DATA/logs/config-audit.jsonl
chmod 644 $DATA/logs/config-audit.jsonl
chattr +a $DATA/logs/config-audit.jsonl   # Linux: append-only at fs level
```

### Phase 3 — Switch to openclaw user to run daemon
```bash
# Drop privileges and start
exec su -s /bin/sh openclaw -c "node /opt/openclaw_install/openclaw.mjs"
```

---

## Resulting intuitive folder structure

```
/opt/
 ┣ openclaw_install/        ← owned by root, READ ONLY for agent
 ┃                            (source, binaries, skills, scripts)
 ┗ openclaw_data/
    ┗ .openclaw/
       ┣ [config files]     ← owned by root:openclaw, agent can READ
       ┗ workspace/         ← owned by openclaw, agent can READ+WRITE
          ┣ SOUL.md         ← exception: owned by root, agent READ ONLY
          ┣ AGENTS.md       ← same, protect if you want
          ┣ MEMORY.md       ← agent writes freely
          ┣ USER.md         ← agent writes freely
          ┗ projects/       ← agent writes freely
```

---

## In a devcontainer context

In `docker-compose.yml` you'd reflect this with two separate mounts:

```yaml
services:
  openclaw:
    user: "openclaw"           # run as restricted user
    volumes:
      - ./openclaw_install:/opt/openclaw_install:ro   # install dir: READ ONLY
      - ./openclaw_data:/opt/openclaw_data:rw         # data dir: READ WRITE
                                                      # (internal perms handle the rest)
```

This way even if the container is compromised, a `:ro` mount gives you a hard kernel-level guarantee that the install directory can't be touched, regardless of what the agent does.

---

The phased approach you're thinking about is the right one — install with elevated privileges, harden permissions, then drop to a restricted user for runtime. This is standard practice for daemons like nginx, postgres, etc. and maps cleanly to how OpenClaw's separation of concerns already works.