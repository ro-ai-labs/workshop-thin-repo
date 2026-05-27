# Build & Ship Runbook (Mihai-only)

Status as of 2026-05-27, T-1 day.

This image is **toolchain-only** (no demo repos baked). Demo clones + per-repo
installs happen inside the container on first reopen via
`.devcontainer/post-create.sh`, against named volumes so subsequent rebuilds
skip all that work. See `docs/README.md` for the participant-side narrative.

**No container registry.** Participants build the image locally from the
cloned repo (`docker pull`, GHCR PATs, and any private registry are out of
the picture). The trade-off is ~10-15 min build time on each participant's
laptop the first time they open the repo (cached after that).

**Plugins are NOT baked into the image.** Bring-your-own — `claude /plugin add
<name>@<marketplace>` inside the container. A named volume at
`/home/vscode/.claude/plugins` keeps those installs across container rebuilds.
The 7 workshop plugins to install on first launch:
hookify, security-guidance, superpowers, pr-review-toolkit, commit-commands,
plugin-dev (all from `claude-plugins-official`), and understand-anything
(from `Lum1104/Understand-Anything`).

## Step 1 — Local build + smoke test (~10-15 min cold)

```bash
cd /home/mihai/workshop-thin-repo

bash scripts/build-local.sh        # toolchain-only build, ~8-15 min cold
bash scripts/run-smoke-test.sh     # ~5 sec; must exit 0
```

Smoke-test only checks the image (toolchains + plugins + Playwright +
cargo writeability). Demo sources are post-create's job — they're verified in
Step 2.

If smoke-test fails: Dockerfile issue; inspect with `docker run --rm -it itss-workshop:local bash`.

## Step 2 — Manual reopen-in-container smoke (one-time, ~15-20 min)

```bash
cd /home/mihai/workshop-thin-repo
code .
# In VS Code: "Reopen in Container"
```

First open builds the image (uses cached layers from Step 1, so ~30s) then
runs `post-create.sh`: clones codex/opencode/twenty into
`${workspaceFolder}/workshop/`, runs `bun install` + `yarn install`, brings up
Twenty's compose, seeds the DB. ~10-15 min wallclock.

Verify by hand after the welcome banner prints:

1. Inside a `claude` session, install the 7 plugins via `/plugin marketplace add ...`
   and `/plugin add ...`. `/plugin list` should then show all 7.
2. `cd ./workshop/twenty && yarn start` → http://localhost:3001 loads (~30s)
3. Right-click `./workshop/drive-share/demo-codex-architecture.html` → Show Preview → page renders
4. In a `claude` session: `/plugin` lists `plugin-dev` (Demo 1 Part 2 uses
   the `plugin-dev:create-plugin` skill to scaffold `./workshop/itss-plugins/` live)
5. **Persistence check:** `docker compose down` the devcontainer, then "Reopen
   in Container" again. Second post-create completes in seconds — the named
   volumes (cargo / bun / dind / plugins) + the workspace bind preserved
   everything, including the plugins you installed.

If any fail, fix in Dockerfile / post-create.sh / scripts, rebuild via
`build-local.sh`, retry.

## Step 3 — Export tarball backup (optional, ~5 min)

For offline-fallback if workshop wifi is hostile and `git clone` doesn't work
either. Tarball can be `docker load`-ed at the venue.

```bash
bash scripts/export-tarball.sh
# Result: itss-workshop-2026.05.28.tar (~1-2 GB)
```

Copy to a USB stick. The tarball is only useful if a participant's `docker
build` fails — they can `docker load < itss-workshop-2026.05.28.tar` and then
re-`Reopen in Container`, and VS Code will find the cached image.

## Step 4 — Push thin repo to GitHub

```bash
gh repo create ro-ai-labs/itss-workshop-2026 --public \
  --description "ITSS Workshop May 28 2026 — devcontainer" \
  --source=. --push
```

## Step 5 — Notify participants (tonight)

Subject: **"ITSS Workshop — set up tonight"**

> Hi all,
>
> Tomorrow's workshop ships with a one-clone setup — no container registry,
> no auth tokens. Please do this **tonight** because the first open builds
> the image locally (~10-15 min) and we don't want to do that on workshop wifi.
>
> **Important: the build is x86_64 (Intel/AMD) only. If you're on Apple Silicon
> (M1/M2/M3) or an ARM PC, follow the manual recipe instead:**
> https://github.com/ro-ai-labs/itss-workshop-2026/blob/main/docs/HOST_SETUP.md
>
> For everyone on x86_64:
>
> 1. Install Docker Desktop + VS Code (+ "Dev Containers" extension)
> 2. Allocate at least 8 GB RAM / 4 CPU / 32 GB disk to Docker Desktop
> 3. `npm i -g @anthropic-ai/claude-code && claude login`
> 4. `git clone https://github.com/ro-ai-labs/itss-workshop-2026`
> 5. Open in VS Code → "Reopen in Container"
> 6. First open builds the image (~10-15 min) then runs post-create
>    (clones demo repos + installs deps, ~10-15 min). Total: ~20-30 min.
>    Subsequent opens: seconds.
>
> README: https://github.com/ro-ai-labs/itss-workshop-2026/blob/main/docs/README.md
> Troubleshooting: https://github.com/ro-ai-labs/itss-workshop-2026/blob/main/docs/troubleshooting.md
>
> Offline fallback (image tarball on USB) available at the workshop if your
> `docker build` fails.
>
> See you tomorrow,
> Mihai

## Known open items

- **Twenty's `demo-after-phase-N` recovery branches** referenced in
  `docs/demo-2.md` may not exist on the ro-ai-labs/twenty fork. If you want
  Layer 2 recovery during the live demo, create them tonight after a clean
  rehearsal pass.

- **API key quota.** Participants need their own Claude API key with
  sufficient quota. The container can't help with that.
