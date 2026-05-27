# ITSS Workshop 2026 — Devcontainer

This devcontainer packages everything you need for the workshop demos:
sources for Codex CLI, opencode, and Twenty CRM; all their dependencies; Claude
Code with 8 workshop plugins pre-installed; Playwright Chromium; and the
participant handout PDFs as offline copies.

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

### 4. Pre-pull the container image

This step is **strongly recommended** the evening before the workshop, so you
don't compete with everyone else's pull on workshop wifi:

```bash
docker pull ghcr.io/ro-ai-labs/itss-workshop:2026.05.28
```

Pull is ~3–4 GB compressed. On a 100 Mbps connection: ~5–10 min.

### 5. Clone this repo and open it

```bash
git clone https://github.com/ro-ai-labs/itss-workshop-2026
cd itss-workshop-2026
code .
```

When VS Code opens, it will detect `.devcontainer/devcontainer.json` and show
"Reopen in Container" in the bottom right. Click it.

First open: ~30 sec to start (image already pulled in step 4). The welcome
banner prints in the terminal when ready.

## Inside the container

Run `claude` from any demo directory:

```bash
cd ~/workshop/codex          # Demo 1a (read-only architecture)
cd ~/workshop/opencode       # Demo 1b
cd ~/workshop/twenty         # Demo 2 (full feature build)
```

Participant handout PDFs and the Demo 1 architecture-HTML fallbacks live at
`~/workshop/drive-share/`.

Demo-specific paste-along prompts are in [`demo-1.md`](demo-1.md) and
[`demo-2.md`](demo-2.md).

For troubleshooting (proxy, RAM, ports, plugins not visible), see
[`troubleshooting.md`](troubleshooting.md).

## Acknowledgements

The container bundles Codex (OpenAI), opencode (anomalyco), Twenty CRM (twentyhq),
plus plugins from `claude-plugins-official` and `Lum1104/Understand-Anything`.
All upstream licenses respected; see each repo's LICENSE file.
