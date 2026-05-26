# Troubleshooting

## "Reopen in Container" button doesn't appear

- Docker Desktop is not running. Launch it.
- The VS Code Dev Containers extension isn't installed. Install it from the
  Extensions marketplace (`ms-vscode-remote.remote-containers`).

## Image pull stalls / times out

You're likely behind a corporate proxy. In Docker Desktop → Settings → Resources
→ Proxies, set HTTP/HTTPS proxy values. Then `docker pull` again.

For npm/yarn proxies inside the container (only matters if you install new
packages later), add to `~/.bashrc`:

```bash
export HTTP_PROXY=http://your.proxy:8080
export HTTPS_PROXY=http://your.proxy:8080
```

## Bind mount fails: "no such file" for `.claude.json` or `.credentials.json`

You haven't run `claude login` on your host yet. Do it:

```bash
# On host:
npm install -g @anthropic-ai/claude-code
claude login
```

Restart Docker Desktop, then "Reopen in Container" again.

## Twenty dev server doesn't come up

Postgres or Redis might not be healthy. Check:

```bash
docker compose -f ~/workshop/twenty/packages/twenty-docker/docker-compose.dev.yml ps
```

If a service is `unhealthy`, wipe and restart:

```bash
docker compose -f ~/workshop/twenty/packages/twenty-docker/docker-compose.dev.yml down -v
docker compose -f ~/workshop/twenty/packages/twenty-docker/docker-compose.dev.yml up -d
cd ~/workshop/twenty && yarn workspace twenty-server database:init:prod
```

## Live Preview shows blank page

Port 3002 might be in use. Change `livePreview.portNumber` in VS Code settings
to e.g. 3010, then right-click → Show Preview again.

## `/plugin list` shows no plugins

The bind mount may have overridden the image's plugin config. Recovery:

```bash
# Inside the container:
cp /etc/skel/.claude/plugins/*.json ~/.claude/plugins/
```

Then restart `claude`.

## GitHub PR extension wants you to sign in

Decline. Demo 3 doesn't need GitHub auth. If you want it for your own repos
later, sign in then.

## Apple Silicon (M1/M2/M3) or ARM PC — image won't run

The container is `linux/amd64` only and we don't ship `linux/arm64`. Running
the amd64 image under Docker Desktop on Apple Silicon technically works via
Rosetta/QEMU emulation, but it's 5–10× slower and Twenty's dev server is
unusable in practice.

Use the host-side manual setup recipe instead: [HOST_SETUP.md](HOST_SETUP.md).
You install Node 24.5, Java 21, Rust, Bun, Maven, and Claude Code directly on
your Mac/ARM machine, clone the demo repos, and run the same demos without the
container. Takes ~30 min one-time.

## Last resort: offline image install

If ghcr.io is unreachable on workshop morning, ask Mihai for the tarball
(USB stick or LAN share). Then:

```bash
docker load -i itss-workshop-2026.05.28.tar
```

Image lands in your local Docker. "Reopen in Container" works as normal.
