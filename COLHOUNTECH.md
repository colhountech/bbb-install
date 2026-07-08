# ColhounTech fork notes

This repository is a fork of [bigbluebutton/bbb-install](https://github.com/bigbluebutton/bbb-install), maintained for ColhounTech BBB deployments.

Use this script URL for installs and upgrades:

```bash
https://raw.githubusercontent.com/colhountech/bbb-install/v3.0.x-release/bbb-install.sh
```

The upstream README still references `bigbluebutton/bbb-install` in many places. For this fork, always use the ColhounTech URL above.

---

## What changed in this fork

### Upgrade-safe default (no extra flags)

Re-running `bbb-install.sh` on a server where BigBlueButton is already installed (`dpkg -s bigbluebutton`) **upgrades packages only**. Existing configuration is not reset to a vanilla install.

**On upgrade, the script:**

- Runs `apt dist-upgrade` for BBB packages (`bigbluebutton`, `bbb-html5`)
- Pulls and restarts Greenlight v3 container images when `-g` is used and Greenlight is already installed
- Pulls and restarts LTI framework container images when LTI is already installed
- Runs `bbb-conf --check`, which re-applies customizations from `apply-config.sh`

**On upgrade, the script does not:**

- Regenerate nginx, HAProxy, or coturn configuration
- Re-run SSL setup or rewrite certificate paths
- Edit FreeSWITCH vars, `bbb-html5.yml`, or `bbb-webrtc-sfu/production.yml`
- Overwrite Greenlight or LTI `.env` files
- Rotate LTI OAuth credentials
- Re-pull Greenlight/LTI nginx configs from Docker images

**On a fresh server** (BBB not yet installed), the script still performs the full first-time installation.

### Other fixes

- **`check_host()`** — DNS/IP validation now runs when `-s` is provided (previously skipped in the normal install path)
- **`env` dump removed** — avoids logging sensitive values (email, LTI credentials) during install

### Fork-only commit

- Script header, examples, and support links point at `colhountech/bbb-install` instead of `bigbluebutton/bbb-install`

---

## Workflow

Use the **same command** for first install and for every subsequent update.

Example (adjust hostname, email, and optional flags to match your server):

```bash
wget -qO- https://raw.githubusercontent.com/colhountech/bbb-install/v3.0.x-release/bbb-install.sh | bash -s -- \
  -w -v jammy-300 -s bbb.example.com -e info@example.com -g
```

| Flag | Purpose |
|------|---------|
| `-w` | UFW firewall (first install only creates `apply-config.sh` stub if missing) |
| `-v jammy-300` | BBB 3.0 on Ubuntu 22.04 |
| `-s` | Hostname |
| `-e` | Let's Encrypt email |
| `-g` | Greenlight v3 (full setup first time; image upgrade on re-run) |
| `-k` | Keycloak (first install with Greenlight only) |
| `-t KEY:SECRET` | LTI framework (full setup first time; image upgrade on re-run) |

**First run:** full BBB (+ Greenlight/LTI if requested) installation.

**Every later run:** package and image upgrades only; configuration preserved; `apply-config.sh` re-applied via `bbb-conf --check`.

Console output on upgrade:

```
bbb-install: BigBlueButton is already installed — upgrading packages only; existing configuration will be preserved.
...
bbb-install: Upgrade complete. Package updates applied; your configuration was not reset.
bbb-install: Custom settings in /etc/bigbluebutton/bbb-conf/apply-config.sh were re-applied.
```

---

## Customizations

Put settings that must survive upgrades in BBB’s supported override locations and in `apply-config.sh`.

### `apply-config.sh` (required for custom re-apply)

```bash
/etc/bigbluebutton/bbb-conf/apply-config.sh
```

This runs automatically at the end of every upgrade via `bbb-conf --check`. Add your custom steps here (extra nginx tweaks, `yq` edits, service restarts, etc.).

On first install with `-w`, the script creates a minimal stub if the file does not exist:

```bash
#!/bin/bash
source /etc/bigbluebutton/bbb-conf/apply-lib.sh
enableUFWRules
```

Replace or extend that file with your own logic.

### Mindset Mastery deployment (tracked in this repo)

Server customizations for `bbb.colhountech.com` are version-controlled under:

```
config/mindsetmastery/
  apply-config.sh          # canonical apply-config (deploy this to the server)
  deploy-apply-config.sh   # push + re-apply in one command
  CUSTOMIZATIONS.md        # full inventory (server + app join flow)
```

Deploy after editing:

```bash
chmod +x config/mindsetmastery/deploy-apply-config.sh
./config/mindsetmastery/deploy-apply-config.sh
ssh root@78.47.120.165 bbb-conf --restart   # when html5 client settings change
```

App-side join userdata and flow are documented in the same `CUSTOMIZATIONS.md` and in the Mindset Mastery repo at `docs/BBB-INTEGRATION.md`.

### Override files (survive package updates)

| Path | Purpose |
|------|---------|
| `/etc/bigbluebutton/bbb-web.properties` | BBB web/API settings |
| `/etc/bigbluebutton/bbb-html5.yml` | HTML5 client configuration |
| `/etc/bigbluebutton/bbb-webrtc-sfu/production.yml` | WebRTC SFU / mediasoup settings |
| `/etc/bigbluebutton/nginx/*.nginx` | Custom nginx snippets |
| `/etc/bigbluebutton/turn-stun-servers.xml` | External TURN configuration (when using `-c`) |
| `~/greenlight-v3/.env` | Greenlight environment (not touched on upgrade) |
| `~/bbb-lti/*/.env` | LTI app environment (not touched on upgrade) |

Keep customizations in these files rather than editing package-owned paths under `/usr/share/` directly.

---

## Fork maintenance

### Relationship to upstream

- **Remote:** `upstream` → `https://github.com/bigbluebutton/bbb-install.git`
- **Branch:** `v3.0.x-release` (BBB 3.0 / Ubuntu 22.04 jammy)

This fork diverged from upstream with one ColhounTech-specific commit (`change git repo to colhountech`) plus the upgrade-safe behaviour described above.

Upstream has continued to receive fixes worth merging periodically, including:

- TURN/STUN XML no longer blindly overwritten on upgrade
- Improved external TURN handling
- Docker Compose v2 (`docker compose` instead of pinned 1.24.0 binary)
- ImageMagick security policy updates
- Optional LiveKit install (`-L`)

**Recommended:** merge `upstream/v3.0.x-release` into this fork when convenient; resolve conflicts while keeping ColhounTech URL references and upgrade-safe default behaviour.

```bash
git fetch upstream
git merge upstream/v3.0.x-release
# resolve conflicts, test, push
```

### Branches

- **`v3.0.x-release`** — production ColhounTech BBB 3.0 installs and upgrades
- Upstream **`master`** / **`v4.0.x-release`** — newer BBB versions; not used by this fork unless migrating

---

## Support

- BBB docs: https://docs.bigbluebutton.org/administration/install
- Upstream issues: https://github.com/bigbluebutton/bbb-install/issues
- This fork: https://github.com/colhountech/bbb-install