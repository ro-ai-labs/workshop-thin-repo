# ITSS Workshop 2026 — Devcontainer

This devcontainer builds a toolchain image locally on your machine (Node 24,
Bun 1.3, Rust 1.93, Claude Code CLI, Playwright Chromium) — no `docker pull`,
no container registry, no auth tokens. On first open, `.devcontainer/post-create.sh`
clones the three demo repos (Codex, opencode, Twenty CRM) into
`${workspaceFolder}/workshop/` on the **host filesystem** and runs
`bun install` / `yarn install`. That way your edits + git state survive
container rebuilds.

Claude Code plugins are **not** baked into the image — install them once
inside a `claude` session (`/plugin marketplace add ...`, `/plugin add ...`)
and a named volume keeps them across rebuilds.

Named volumes persist the things that don't sit on the workspace bind-mount —
cargo cache, bun's global cache, and Docker-in-Docker's storage (so Twenty's
Postgres data + compose state survive too). On a second `Reopen in Container`,
post-create skips everything that's already there; setup completes in seconds
instead of minutes.

**First-time setup wallclock:** ~20–30 min (image build + cloning + bun + yarn,
mostly network-bound). **Subsequent reopens:** seconds.

> ## ⚠️ Host requirement: x86_64 (Intel/AMD) only
>
> The container image is `linux/amd64` only. **Apple Silicon (M1/M2/M3) Macs
> and ARM-based PCs are not supported** by this devcontainer.
>
> If you're on an unsupported host, follow [HOST_SETUP.md](HOST_SETUP.md) for
> the manual setup recipe — it walks you through installing the same
> toolchains and cloning the same repos on your host directly. The demos
> still work; you just skip the container.

## Before workshop day

Do these once, on your host machine.

### 1. Install Docker Desktop + VS Code

- Docker Desktop: https://www.docker.com/products/docker-desktop
- VS Code: https://code.visualstudio.com/
- VS Code "Dev Containers" extension: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers

### 2. Allocate Docker Desktop resources

Open Docker Desktop → Settings → Resources. Set at minimum:

| Resource | Minimum | Comfortable |
|---|---|---|
| CPUs | 4 | 6 |
| Memory | 8 GB | 12 GB |
| Disk | 32 GB | 64 GB |

### 3. Install Claude Code on your host

```bash
npm install -g @anthropic-ai/claude-code
claude login
```

This creates `~/.claude.json` and `~/.claude/.credentials.json` on your host.
The container binds these in so authentication carries over.

(Plugins are pre-installed inside the container. You don't need to install them
on host for the container to work.)

### 4. Clone this repo and open it

```bash
git clone https://github.com/ro-ai-labs/itss-workshop-2026
cd itss-workshop-2026
code .
```

When VS Code opens, it will detect `.devcontainer/devcontainer.json` and show
"Reopen in Container" in the bottom right. Click it.

**First open** does two things in sequence:

1. Builds the container image locally from `.devcontainer/Dockerfile` — installs
   Node 24, Bun, Rust, Claude Code CLI, Playwright Chromium. ~10-15 min.
2. Runs `post-create.sh` — clones the demo repos, runs `bun install` + `yarn install`,
   starts Twenty's compose, seeds the DB. Another ~10-15 min.

Total first-open: ~20-30 min. VS Code shows progress for both phases. The
welcome banner prints in the terminal when post-create finishes.

**Every later open:** seconds — Docker caches the built image, and the
workspace mount + named volumes preserve the post-create work.

## Inside the container

Run `claude` from any demo directory:

```bash
cd ./workshop/codex          # Demo 1a (read-only architecture)
cd ./workshop/opencode       # Demo 1b
cd ./workshop/twenty         # Demo 2 (full feature build)
```

Participant handout PDFs and the Demo 1 architecture-HTML fallbacks live at
`./workshop/drive-share/`.

Demo-specific paste-along prompts are in [`demo-1.md`](demo-1.md) and
[`demo-2.md`](demo-2.md).

For troubleshooting (proxy, RAM, ports, plugins not visible), see
[`troubleshooting.md`](troubleshooting.md).

## Acknowledgements

The container bundles Codex (OpenAI), opencode (anomalyco), Twenty CRM (twentyhq),
plus plugins from `claude-plugins-official` and `Lum1104/Understand-Anything`.
All upstream licenses respected; see each repo's LICENSE file.
