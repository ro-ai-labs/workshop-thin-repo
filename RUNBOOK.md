# Build & Ship Runbook (Mihai-only)

Status as of 2026-05-27, T-1 day. All files authored, build not yet run.

This runbook covers Tasks 29–32 from the implementation plan: the parts that
require your hands on keyboard (interactive Claude sessions, Docker wallclock,
ghcr.io auth, GitHub publish).

## State at handoff

Repo at `/home/mihai/workshop-thin-repo/` — 6 commits, all source authored.
Build args at `/tmp/itss-build-vars.sh`.

```
$ cd /home/mihai/workshop-thin-repo
$ git log --oneline
6d85591 docs: participant README, per-demo paste-alongs, troubleshooting, VERSIONS
2a450b1 scripts: prepare/build/test/push/export pipeline
a79010c config: devcontainer.json + post-create/start scripts + multi-root workspace
4e75007 build: full multi-arch Dockerfile (15 layers) + Twenty dev env
4bd4fdc test: smoke-test script asserts all 6 success criteria
5f955de init: thin repo skeleton with LICENSE, .gitignore, .dockerignore
```

## Step 1 — (no-op) Understand-Anything graphs already in the forks

The `.understand-anything/` knowledge graphs for `ro-ai-labs/twenty` and
`ro-ai-labs/opencode` are already committed to those forks. They arrive
inside the container via `git clone` at build time — no host staging needed.

Codex's graph is intentionally not baked (decided 2026-05-27). Demo 1 Step
P2.5 falls back to the pre-rendered codex architecture HTML; if a participant
wants the live dashboard, they run `/understand` themselves on the day
(3-5 min, costs tokens).

## Step 2 — Local build + smoke test loop (~20-40 min wallclock)

```bash
cd /home/mihai/workshop-thin-repo
source /tmp/itss-build-vars.sh

# Stage build context (deliverables + host plugins) and build
bash scripts/build-local.sh        # ~10-20 min on first cold build
bash scripts/run-smoke-test.sh     # ~10 sec; must exit 0
```

If smoke-test reports failures:

- `understand-anything` graph checks for codex — see Step 1 (commit `.understand-anything/` to ro-ai-labs/codex), then rebuild. Graph checks for twenty/opencode failing means the fork doesn't have the committed graphs (re-verify they're there)
- Plugin checks — `ls /home/mihai/workshop-thin-repo/build-context/claude-plugins/cache/` should have all 8 plugin dirs; if not, your host plugins aren't installed
- Twenty/codex/opencode source checks — your ro-ai-labs forks may not have the expected branch (verify `git ls-remote https://github.com/ro-ai-labs/twenty | grep demo`)
- Toolchain checks — Dockerfile issue; inspect with `docker run --rm -it itss-workshop:local bash`

Iterate `build-local.sh` → `run-smoke-test.sh` until all green.

## Step 3 — Manual reopen-in-container smoke (one-time, ~5 min)

```bash
cd /home/mihai/workshop-thin-repo
code .
# In VS Code: "Reopen in Container"
```

Inside the running container, verify by hand:

1. Welcome banner prints in terminal
2. `claude /plugin list` shows 8 plugins
3. `cd ~/workshop/twenty && yarn start` → http://localhost:3001 loads (give it ~30s)
4. Right-click `~/workshop/drive-share/demo-codex-architecture.html` → Show Preview → page renders
5. In a `claude` session: `/plugin` lists `plugin-dev` (Demo 1 Part 2 uses
   the `plugin-dev:create-plugin` skill to scaffold `~/workshop/itss-plugins/` live)

If any fail, fix in the Dockerfile / scripts, rebuild via `build-local.sh`, retry.

## Step 4 — Build and push to ghcr.io (~15-25 min wallclock)

> **Note (2026-05-27 design change):** dropped multi-arch in favor of amd64-only.
> Apple Silicon and ARM PCs now follow `docs/HOST_SETUP.md` for manual host setup
> instead. Build time drops from 30-60 min to 15-25 min, removing a category of
> QEMU-related failure modes on T-1 day.

```bash
# Authenticate to ghcr.io
docker login ghcr.io -u ro-ai-labs
# Password = a GitHub PAT with write:packages + read:packages scopes
# Generate at: https://github.com/settings/tokens

# Build + push (single-arch amd64, ~15-25 min)
cd /home/mihai/workshop-thin-repo
bash scripts/build-and-push.sh
```

Expected wallclock: 30–60 min (arm64 leg uses QEMU emulation; slow).

Verify the image is pushed:

```bash
docker buildx imagetools inspect ghcr.io/ro-ai-labs/itss-workshop:2026.05.28
```

Should show `linux/amd64` in the manifest.

## Step 5 — Make package public

GitHub UI: https://github.com/orgs/ro-ai-labs/packages/container/itss-workshop/settings
→ "Change visibility" → Public

Or via API:

```bash
gh api -X PATCH /orgs/ro-ai-labs/packages/container/itss-workshop \
  -f visibility=public
```

Verify a logged-out browser can see the package.

## Step 6 — Export tarball backup (~5 min)

In case ghcr.io is unreachable tomorrow morning:

```bash
cd /home/mihai/workshop-thin-repo
bash scripts/export-tarball.sh
# Result: itss-workshop-2026.05.28.tar (~3-5 GB)
ls -lh itss-workshop-2026.05.28.tar
```

Copy to a USB stick. Also upload to a Drive folder (shareable link).

## Step 7 — Push thin repo to GitHub

```bash
cd /home/mihai/workshop-thin-repo
gh repo create ro-ai-labs/itss-workshop-2026 --public \
  --description "ITSS Workshop May 28 2026 — devcontainer" \
  --source=. --push
```

Or manually:

```bash
gh repo create ro-ai-labs/itss-workshop-2026 --public --description "..."
git remote add origin git@github.com:ro-ai-labs/itss-workshop-2026.git
git push -u origin main
```

## Step 8 — Notify participants (tonight)

Subject line idea: **"ITSS Workshop — set up tonight"**

Body:

> Hi all,
>
> Tomorrow's workshop ships with a one-click setup. Please do this **tonight**:
>
> **Important: the container image is x86_64 (Intel/AMD) only. If you're on
> Apple Silicon (M1/M2/M3) or an ARM PC, skip steps 1–4 and follow the manual
> recipe at:**
> https://github.com/ro-ai-labs/itss-workshop-2026/blob/main/docs/HOST_SETUP.md
>
> For everyone on x86_64:
>
> 1. Install Docker Desktop + VS Code (+ "Dev Containers" extension)
> 2. Allocate at least 8 GB RAM / 4 CPU / 32 GB disk to Docker Desktop
> 3. `npm i -g @anthropic-ai/claude-code && claude login`
> 4. **Pre-pull the image (~4 GB, ~10 min):**
>    ```
>    docker pull ghcr.io/ro-ai-labs/itss-workshop:2026.05.28
>    ```
> 5. `git clone https://github.com/ro-ai-labs/itss-workshop-2026`
> 6. Open in VS Code → "Reopen in Container"
>
> README: https://github.com/ro-ai-labs/itss-workshop-2026/blob/main/docs/README.md
> Troubleshooting: https://github.com/ro-ai-labs/itss-workshop-2026/blob/main/docs/troubleshooting.md
>
> Offline fallback (tarball on USB) available at the workshop if pull fails.
>
> See you tomorrow,
> Mihai

## Known open items

- **Twenty's `demo-after-phase-N` recovery branches** referenced in `docs/demo-2.md`
  may not exist on the ro-ai-labs/twenty fork. If you want Layer 2 recovery
  during the live demo, create them tonight after a clean rehearsal pass.

- **Opencode branch name** is blank in VERSIONS.md (`/tmp/itss-build-vars.sh`
  doesn't set OPENCODE_BRANCH). The SHA is pinned so the build works; just a
  cosmetic gap in VERSIONS.md.

- **Plugin install in the image is approximate.** The Dockerfile copies your
  host's `~/.claude/plugins/cache/` into the image and rebuilds native deps
  per-arch, but `installed_plugins.json` / `known_marketplaces.json` paths
  inside the registry files may reference your host paths. If `/plugin list`
  inside the container shows nothing, the recovery is documented in
  `docs/troubleshooting.md` (`cp /etc/skel/.claude/plugins/*.json ~/.claude/plugins/`).

  If you hit this and have time, sed-edit the JSON files in
  `build-context/claude-plugins/` to swap `/home/mihai` → `/home/vscode`
  before re-running `build-local.sh`.

- **API key quota.** Participants need their own Claude API key with sufficient
  quota. The container can't help with that.
