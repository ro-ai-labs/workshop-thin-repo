# Manual host setup (devcontainer fallback)

Use this if the devcontainer doesn't work for you — most commonly because you're
on **Apple Silicon (M1/M2/M3) or an ARM PC** where the linux/amd64 image won't
run at usable speed.

This recipe installs the same toolchains on your host directly. Demos work the
same; you just `cd` into directories on your host instead of inside a container.

**Time:** ~30–45 min one-time setup.

---

## 1. Toolchains (install in this order)

### Node 24.5 + Yarn 4.13 + Bun 1.3.14

Using `nvm` (Node Version Manager) on Mac/Linux:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
# Restart shell, then:
nvm install 24.5.0
nvm use 24.5.0
node --version    # v24.5.x

corepack enable
corepack prepare yarn@4.13.0 --activate
corepack prepare pnpm@latest --activate

curl -fsSL https://bun.sh/install | bash -s "bun-v1.3.14"
bun --version     # 1.3.14
```

On Windows: use `nvm-windows` (https://github.com/coreybutler/nvm-windows) for
Node, then enable Corepack. Install Bun via `npm install -g bun@1.3.14`.

### Rust 1.93.0

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# Accept defaults, then:
rustup install 1.93.0
rustup default 1.93.0
rustup component add clippy rustfmt rust-src
rustc --version    # 1.93.0
```

### Docker (for Twenty's Postgres + Redis)

- Mac: Docker Desktop or Colima or OrbStack
- Linux: `sudo apt install docker.io docker-compose-plugin`
- Windows: Docker Desktop

Verify: `docker compose version` shows v2.x.

### Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
claude login
```

## 2. Workshop plugins (host-side)

Inside an interactive `claude` session in any directory:

```
/plugin marketplace add Lum1104/Understand-Anything
/plugin install hookify@claude-plugins-official
/plugin install security-guidance@claude-plugins-official
/plugin install superpowers@claude-plugins-official
/plugin install pr-review-toolkit@claude-plugins-official
/plugin install understand-anything
/plugin install code-review@claude-plugins-official
/plugin install commit-commands@claude-plugins-official
/plugin install plugin-dev@claude-plugins-official
```

Add Playwright MCP for Demo 2 Phase 5:

```bash
claude mcp add playwright npx @playwright/mcp@latest
```

## 3. Clone the demo repos

Pick a working directory; the workshop expects `~/workshop/`:

```bash
mkdir -p ~/workshop && cd ~/workshop

# Demo 1a: Codex CLI (Rust) — read-only architecture exploration
git clone https://github.com/ro-ai-labs/codex.git
cd codex && git checkout demo && (cd codex-rs && cargo fetch) && cd ..

# Demo 1b: opencode (TypeScript via Bun)
git clone https://github.com/ro-ai-labs/opencode.git
cd opencode && git checkout demo && bun install && cd ..

# Demo 2: Twenty CRM (Yarn 4 Berry monorepo)
git clone https://github.com/ro-ai-labs/twenty.git
cd twenty && git checkout demo
cp .env.example .env
# Edit .env to point Postgres/Redis at localhost (compose hostnames don't work outside the container)
sed -i.bak 's|@db:5432|@localhost:5432|; s|@redis:6379|@localhost:6379|' .env
yarn install
docker compose -f packages/twenty-docker/docker-compose.dev.yml up -d
yarn workspace twenty-server database:init:prod
cd ..
```

## 4. Per-demo verification

### Demo 1

```bash
cd ~/workshop/codex && claude    # type the P1 prompt from docs/demo-1.md
```

### Demo 2

In one terminal:
```bash
cd ~/workshop/twenty && yarn start
# Wait for http://localhost:3001 to load
```

In another:
```bash
cd ~/workshop/twenty && claude   # type the Phase 1 prompt from docs/demo-2.md
```

## 5. Architecture HTMLs (Demo 1 viewing)

The fallback architecture HTMLs use `file://` to drill into source files. On Mac,
Chrome blocks this by default. Create a one-word launcher:

```bash
mkdir -p ~/.local/bin
cat > ~/.local/bin/chrome-workshop <<'EOF'
#!/usr/bin/env bash
# Mac:
exec /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --allow-file-access-from-files \
  --user-data-dir=/tmp/chrome-workshop "$@"
# Linux:
# exec google-chrome --allow-file-access-from-files --user-data-dir=/tmp/chrome-workshop "$@"
EOF
chmod +x ~/.local/bin/chrome-workshop
# Add ~/.local/bin to PATH if not already
```

Test: `chrome-workshop ~/workshop/codex/demo-examples/codex-architecture.html`

## Cheatsheets

The PDF cheatsheets aren't auto-installed in this manual path. Ask Mihai for the
Drive folder link, or grab them from the workshop-thin-repo (they're not in the
git tree — they're baked into the container image only). Mihai will share a
public Drive folder on workshop morning.

## You're set

The demos work the same way as in the container. The only thing you give up is
the auto-managed environment — when something breaks (Twenty migration fails,
Postgres won't start), you debug it on your host instead of `docker compose down -v`.

If you hit blockers, ask in the workshop Slack channel.
