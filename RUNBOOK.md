# Build & Ship Runbook (Mihai-only)

Status as of 2026-05-27, T-1 day.

This image is **toolchain-only** (no demo repos baked). Demo clones + per-repo
installs happen inside the container on first reopen via
`.devcontainer/post-create.sh`, against named volumes so subsequent rebuilds
skip all that work. See `docs/README.md` for the participant-side narrative.

## Step 1 — Local build + smoke test (~10-15 min cold)

```bash
cd /home/mihai/workshop-thin-repo

bash scripts/build-local.sh        # toolchain-only build, ~8-15 min cold
bash scripts/run-smoke-test.sh     # ~5 sec; must exit 0
```

Smoke-test now only checks the image (toolchains + plugins + Playwright +
cargo writeability). Demo sources are post-create's job — they're verified in
Step 2.

If smoke-test fails:

- Plugin checks — `ls build-context/claude-plugins/cache/` should have all 8
  plugin dirs; if not, your host plugins aren't installed.
- Toolchain checks — Dockerfile issue; inspect with `docker run --rm -it itss-workshop:local bash`.

## Step 2 — Manual reopen-in-container smoke (one-time, ~15-20 min)

```bash
cd /home/mihai/workshop-thin-repo
code .
# In VS Code: "Reopen in Container"
```

First open runs `post-create.sh`: clones codex/opencode/twenty into
`${workspaceFolder}/workshop/`, runs `bun install` + `yarn install`, brings up
Twenty's compose, seeds the DB. ~10-15 min wallclock.

Verify by hand after the welcome banner prints:

1. `claude /plugin list` shows 8 plugins
2. `cd ~/workshop/twenty && yarn start` → http://localhost:3001 loads (~30s)
3. Right-click `~/workshop/drive-share/demo-codex-architecture.html` → Show Preview → page renders
4. In a `claude` session: `/plugin` lists `plugin-dev` (Demo 1 Part 2 uses
   the `plugin-dev:create-plugin` skill to scaffold `~/workshop/itss-plugins/` live)
5. **Persistence check:** `docker compose down` the devcontainer, then "Reopen
   in Container" again. Second post-create completes in seconds — the named
   volumes (cargo / bun / dind) + the workspace bind preserved everything.

If any fail, fix in Dockerfile / post-create.sh / scripts, rebuild via
`build-local.sh`, retry.

## Step 3 — Build and push to ghcr.io (~8-15 min wallclock)

```bash
docker login ghcr.io -u ro-ai-labs
# Password = a GitHub PAT with write:packages + read:packages scopes
# Generate at: https://github.com/settings/tokens

cd /home/mihai/workshop-thin-repo
bash scripts/build-and-push.sh
```

Verify:

```bash
docker buildx imagetools inspect ghcr.io/ro-ai-labs/itss-workshop:2026.05.28
```

Should show `linux/amd64`.

## Step 4 — Make package public

GitHub UI: https://github.com/orgs/ro-ai-labs/packages/container/itss-workshop/settings
→ "Change visibility" → Public

Or via API:

```bash
gh api -X PATCH /orgs/ro-ai-labs/packages/container/itss-workshop \
  -f visibility=public
```

## Step 5 — Export tarball backup (~5 min)

In case ghcr.io is unreachable tomorrow:

```bash
bash scripts/export-tarball.sh
# Result: itss-workshop-2026.05.28.tar (~1-2 GB now that demos aren't baked)
```

Copy to a USB stick. Also upload to a Drive folder.

## Step 6 — Push thin repo to GitHub

```bash
gh repo create ro-ai-labs/itss-workshop-2026 --public \
  --description "ITSS Workshop May 28 2026 — devcontainer" \
  --source=. --push
```

## Step 7 — Notify participants (tonight)

Subject: **"ITSS Workshop — set up tonight"**

> Hi all,
>
> Tomorrow's workshop ships with a near-one-click setup. Please do this **tonight**:
>
> **Important: the container image is x86_64 (Intel/AMD) only. If you're on
> Apple Silicon (M1/M2/M3) or an ARM PC, follow the manual recipe instead:**
> https://github.com/ro-ai-labs/itss-workshop-2026/blob/main/docs/HOST_SETUP.md
>
> For everyone on x86_64:
>
> 1. Install Docker Desktop + VS Code (+ "Dev Containers" extension)
> 2. Allocate at least 8 GB RAM / 4 CPU / 32 GB disk to Docker Desktop
> 3. `npm i -g @anthropic-ai/claude-code && claude login`
> 4. **Pre-pull the image (~1-2 GB, ~5 min):**
>    ```
>    docker pull ghcr.io/ro-ai-labs/itss-workshop:2026.05.28
>    ```
> 5. `git clone https://github.com/ro-ai-labs/itss-workshop-2026`
> 6. Open in VS Code → "Reopen in Container"
> 7. First open runs post-create (clones repos + installs deps): ~10-15 min.
>    Subsequent opens: instant.
>
> README: https://github.com/ro-ai-labs/itss-workshop-2026/blob/main/docs/README.md
> Troubleshooting: https://github.com/ro-ai-labs/itss-workshop-2026/blob/main/docs/troubleshooting.md
>
> Offline fallback (image tarball on USB) available at the workshop if pull fails.
>
> See you tomorrow,
> Mihai

## Known open items

- **Twenty's `demo-after-phase-N` recovery branches** referenced in
  `docs/demo-2.md` may not exist on the ro-ai-labs/twenty fork. If you want
  Layer 2 recovery during the live demo, create them tonight after a clean
  rehearsal pass.

- **Plugin install in the image is approximate.** The Dockerfile copies your
  host's `~/.claude/plugins/cache/` into the image and rebuilds native deps,
  but `installed_plugins.json` / `known_marketplaces.json` paths inside the
  registry files may reference your host paths. If `/plugin list` inside the
  container shows nothing, recovery is documented in
  `docs/troubleshooting.md` (`cp /etc/skel/.claude/plugins/*.json ~/.claude/plugins/`).

- **API key quota.** Participants need their own Claude API key with
  sufficient quota. The container can't help with that.
