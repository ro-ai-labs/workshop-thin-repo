# Manual host setup (devcontainer fallback)

Use this if the devcontainer doesn't work for you - most commonly because you're
on **Apple Silicon (M1/M2/M3) or an ARM PC** where the `linux/amd64` image
won't run at usable speed.

This recipe installs the same toolchains, clones the same demo repos at the
same pinned SHAs, and sets up the same env that `.devcontainer/Dockerfile` +
`.devcontainer/post-create.sh` set up automatically. The demos themselves
(see `demo-1.md`, `demo-2.md`) work identically; you just `cd` into directories
on your host instead of inside a container.

**Time:** ~30-45 min one-time setup.

The source of truth for pinned versions is [`VERSIONS.md`](../VERSIONS.md) and
[`.devcontainer/versions.env`](../.devcontainer/versions.env). The commands
below mirror those; if you bump a version in one, update the other.

---

## 0. Clone the workshop thin repo

This repo carries the docs, the `drive-share/` PDFs + architecture HTMLs, and
the `.devcontainer/` config. The demo repos clone into `./workshop/` under it
(that path is in `.gitignore` - same convention the container uses).

```bash
git clone https://github.com/ro-ai-labs/workshop-thin-repo.git
cd workshop-thin-repo
```

Everything below runs from this directory.

---

## 1. Toolchains

Pinned versions match `VERSIONS.md`. Install in this order.

### Node 24.5.0 + Yarn 4.13.0 + pnpm + Bun 1.3.14

`nvm` on macOS/Linux:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
# Restart shell, then:
nvm install 24.5.0
nvm alias default 24.5.0
node --version    # v24.5.0

corepack enable
corepack prepare yarn@4.13.0 --activate
corepack prepare pnpm@latest --activate
yarn --version    # 4.13.0

curl -fsSL https://bun.sh/install | bash -s "bun-v1.3.14"
bun --version     # 1.3.14
```

Windows: use [`nvm-windows`](https://github.com/coreybutler/nvm-windows) for
Node, then enable Corepack. Install Bun via `npm install -g bun@1.3.14`.

### Rust 1.93.0 (clippy, rustfmt, rust-src)

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
  -y --default-toolchain 1.93.0 \
  --component clippy --component rustfmt --component rust-src
rustc --version    # 1.93.0
```

### Docker (for Twenty's Postgres + Redis)

- macOS: Docker Desktop or Colima or OrbStack
- Linux: `sudo apt install docker.io docker-compose-plugin`
- Windows: Docker Desktop

Verify: `docker compose version` shows v2.x.

### Claude Code CLI (native installer)

Anthropic's current install channel - same one the container uses. Replaces
the older `npm install -g @anthropic-ai/claude-code` distribution that the CLI
itself prompts you to migrate away from.

```bash
curl -fsSL https://claude.ai/install.sh | bash
# Ensure ~/.local/bin is on PATH, then:
claude --version
claude login
```

### Playwright Chromium (Demo 2 e2e validation)

The container bakes Chromium so the workshop's Playwright MCP launches with
zero network on the day. Do the same locally:

```bash
npx --yes playwright@latest install chromium
```

---

## 2. Clone demo repos at pinned SHAs

These mirror `.devcontainer/post-create.sh`. Pinning to SHA (not just `demo`)
is what guarantees you get the same starting state as everyone else - the
`demo` branch may move between now and workshop day.

```bash
mkdir -p ./workshop && cd ./workshop

# Demo 1a - Codex CLI (Rust, read-only architecture exploration)
git clone --filter=blob:none https://github.com/ro-ai-labs/codex.git
( cd codex \
  && git fetch origin demo:demo 2>/dev/null || true \
  && git checkout 5349d134ee0e4e82d580d45080bbf42cd0caeb5b )

# Demo 1b - opencode (TypeScript via Bun)
git clone --filter=blob:none https://github.com/ro-ai-labs/opencode.git
( cd opencode \
  && git fetch origin demo:demo 2>/dev/null || true \
  && git checkout 8e4b24178a411a78011b6024212422d9a98c6375 )

# Demo 2 - Twenty CRM (Yarn 4 Berry monorepo)
git clone --filter=blob:none https://github.com/ro-ai-labs/twenty.git
( cd twenty \
  && git fetch origin demo:demo 2>/dev/null || true \
  && git checkout ca96c78a81331a5d14b78002e325c5800dac2c3c )

cd ..
```

---

## 3. Per-repo dep installs

Mirrors `post-create.sh`'s install steps. Idempotent - safe to re-run.

```bash
# opencode: bun install
( cd ./workshop/opencode && bun install --frozen-lockfile )    # ~2-3 min

# codex: warm the cargo registry cache (read-only demo, but speeds first build)
( cd ./workshop/codex/codex-rs && cargo fetch )                # ~1-2 min

# twenty: yarn install (slowest step)
( cd ./workshop/twenty && yarn install --immutable )           # ~8-12 min
```

---

## 4. Twenty environment

Twenty's monorepo expects `.env` at `packages/twenty-server/` and
`packages/twenty-front/` (NOT at the repo root). The `.env.example` defaults
point at `localhost:5432` / `localhost:6379`, which is exactly what we want on
the host - so just copy them, no edits needed.

```bash
cp ./workshop/twenty/packages/twenty-server/.env.example ./workshop/twenty/packages/twenty-server/.env
cp ./workshop/twenty/packages/twenty-front/.env.example  ./workshop/twenty/packages/twenty-front/.env
```

Do NOT run `database:init:prod` here. The DB gets reset LIVE during Demo 2
pre-flight (`npx nx database:reset twenty-server`) so participants see the
init step.

---

## 5. Claude plugins

Same set the workshop's Demo 1 pre-flight installs - and the same omission:
`hookify` is NOT installed here. It gets installed LIVE in Demo 1 Phase 4 so
the install moment is part of the demo. If you've installed it from a prior
session, uninstall it (`/plugin uninstall hookify`) before workshop day.

`claude-plugins-official` ships built-in - no `marketplace add` needed. Only
the third-party `Lum1104/Understand-Anything` needs an explicit add.

Inside a `claude` session in any directory:

```
/plugin marketplace add Lum1104/Understand-Anything
/plugin install superpowers@claude-plugins-official
/plugin install plugin-dev@claude-plugins-official
/plugin install security-guidance@claude-plugins-official
/plugin install pr-review-toolkit@claude-plugins-official
/plugin install understand-anything@understand-anything
```

Verify:

```
/plugin list
```

## 6. Playwright MCP

Demo 2's e2e validation uses Playwright via MCP. Register it once on your host:

```bash
claude mcp add playwright npx @playwright/mcp@latest
```

Verify (inside `claude`):

```
/mcp list
```

---

## 7. Workshop-day startup

### Demo 1

Two `claude` sessions, one per repo:

```bash
# Terminal 1
cd ./workshop/codex && claude

# Terminal 2
cd ./workshop/opencode && claude
```

Then paste the P1 prompt from [`demo-1.md`](demo-1.md).

### Demo 2

Three terminals. The bare-`docker run` Postgres + Redis match the demo script
exactly - same commands you'll paste in front of the room.

```bash
# Terminal 1 - infra
docker run -d --name twenty-postgres \
  -p 5432:5432 \
  -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=default \
  postgres:16
docker run -d --name twenty-redis -p 6379:6379 redis

# Terminal 2 - platform
cd ./workshop/twenty
nvm use                            # reads .nvmrc, picks the right Node
npx nx database:reset twenty-server
npx nx start                       # wait for http://localhost:3001

# Terminal 3 - Claude session
cd ./workshop/twenty && claude
```

Teardown:

```bash
docker rm -f twenty-postgres twenty-redis
```

---

## 8. Architecture HTMLs (Demo 1 fallback viewing)

Pre-rehearsed architecture pages live in `./drive-share/`:

- `demo-codex-architecture.html`
- `demo-opencode-architecture.html`

They use `file://` links to drill into source. Chrome blocks `file://` ->
`file://` navigation by default, so create a one-word launcher:

**macOS:**

```bash
mkdir -p ~/.local/bin
cat > ~/.local/bin/chrome-workshop <<'EOF'
#!/usr/bin/env bash
exec /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --allow-file-access-from-files \
  --user-data-dir=/tmp/chrome-workshop "$@"
EOF
chmod +x ~/.local/bin/chrome-workshop
# Ensure ~/.local/bin is on PATH
```

**Linux:**

```bash
mkdir -p ~/.local/bin
cat > ~/.local/bin/chrome-workshop <<'EOF'
#!/usr/bin/env bash
exec google-chrome --allow-file-access-from-files \
  --user-data-dir=/tmp/chrome-workshop "$@"
EOF
chmod +x ~/.local/bin/chrome-workshop
```

**Windows (PowerShell):** launch Chrome with the same two flags pointing
`--user-data-dir` at a temp folder of your choice.

Test:

```bash
chrome-workshop ./drive-share/demo-codex-architecture.html
```

---

## 9. Cheatsheets

The PDF handouts are checked into this repo at `./drive-share/`:

- `00_README.pdf`, `00_Workshop_Handout.pdf`
- `01_CLAUDE_AGENTS_md_Cheatsheet.pdf`
- `02_Kill_Signal_Decision_Card.pdf`
- `03_MCP_Plugin_Supply_Chain_Checklist.pdf`
- `04_Repo_Architecture_Mapping_Prompt.pdf`
- `05_Documentation_Mindmap_Prompt.pdf`
- `06_Manager_Day7_Worksheet.pdf`

Open them straight from your file manager - no Drive link needed.

---

## You're set

The demos work the same way as in the container. The only thing you give up
is the auto-managed environment - when something breaks (Twenty migration
fails, Postgres won't start), you debug it on your host instead of
`docker compose down -v` + reopen.

If you hit blockers, see [`troubleshooting.md`](troubleshooting.md) or ask in
the workshop Slack channel.
