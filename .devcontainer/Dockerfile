# syntax=docker/dockerfile:1.6
# ITSS Workshop 2026 — devcontainer image (linux/amd64 only)
# Apple Silicon and ARM PCs are NOT supported by this image. Those users follow
# docs/HOST_SETUP.md for manual host setup instead.
# Build with: docker buildx build --platform linux/amd64 ...
#   --build-arg CODEX_SHA=<sha>
#   --build-arg OPENCODE_SHA=<sha>
#   --build-arg TWENTY_SHA=<sha>
#   --build-arg TWENTY_BRANCH=demo
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG TARGETARCH

# Locale + time zone (workshop is in Bucharest)
ENV TZ=Europe/Bucharest \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# ---- Layer 1: OS packages + Playwright Chromium deps ----
# git already present in base; add the rest. Playwright deps included so
# chromium runs headless without further apt at first launch.
RUN apt-get update && apt-get install -y --no-install-recommends \
      tzdata ca-certificates curl wget unzip jq tree python3 python3-pip \
      build-essential pkg-config libssl-dev \
      libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
      libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libxshmfence1 \
      libpangocairo-1.0-0 libpango-1.0-0 libcairo2 libgtk-3-0 libasound2 \
      fonts-liberation fonts-noto-color-emoji \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

LABEL org.opencontainers.image.source="https://github.com/ro-ai-labs/itss-workshop-2026"
LABEL org.opencontainers.image.description="ITSS Workshop May 28 2026 — Devcontainer"

# ---- Layer 2: Node 24.5 via NodeSource + Corepack (Yarn 4.13, pnpm) ----
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/* \
 && node --version | grep -E "^v24\." \
 && npm --version

RUN corepack enable \
 && corepack prepare yarn@4.13.0 --activate \
 && corepack prepare pnpm@latest --activate \
 && yarn --version | grep -E "^4\." \
 && pnpm --version

# ---- Layer 3: Bun 1.3.14 (opencode's packageManager) ----
RUN curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash -s "bun-v1.3.14" \
 && ln -sf /usr/local/bin/bun /usr/local/bin/bunx \
 && bun --version | grep -E "^1\.3\."

# ---- Layer 4: Rust 1.93.0 with clippy/rustfmt/rust-src (codex's toolchain) ----
# (Java/Maven layer dropped along with Demo 3, 2026-05-27.)
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
      -y --default-toolchain 1.93.0 \
      --component clippy --component rustfmt --component rust-src \
 && rustc --version | grep "1.93.0" \
 && cargo --version

# ---- Layer 5: Claude Code CLI + docker-compose v1 shim ----
RUN npm install -g @anthropic-ai/claude-code \
 && claude --version

# docker-compose v1 compat shim — deliverables docs sometimes say
# "docker-compose up" while modern is "docker compose". DinD provides v2.
RUN printf '#!/usr/bin/env bash\nexec docker compose "$@"\n' > /usr/local/bin/docker-compose \
 && chmod +x /usr/local/bin/docker-compose

# Ensure vscode user owns .cache for npm/playwright/bun installs
RUN mkdir -p /home/vscode/.cache /home/vscode/.bun \
 && chown -R vscode:vscode /home/vscode

USER vscode
WORKDIR /home/vscode

# ---- Layer 6: Claude Code plugins (copied from host, rebuilt in container) ----
# Host plugins are staged at build-context/claude-plugins/ by
# scripts/prepare-build-context.sh. node_modules are stripped during staging
# so we rebuild them inside the container below — handles the host-WSL2 vs
# Linux-container path differences cleanly, and would naturally extend to other
# different native binaries: esbuild, rollup, lightningcss, tailwind-oxide).
USER root
RUN mkdir -p /home/vscode/.claude/plugins/cache \
 && chown -R vscode:vscode /home/vscode/.claude
USER vscode

# Copy plugin cache (sources only, no node_modules — those are arch-specific)
COPY --chown=vscode:vscode build-context/claude-plugins/cache /home/vscode/.claude/plugins/cache/
# Copy registry files (installed_plugins.json + known_marketplaces.json)
COPY --chown=vscode:vscode build-context/claude-plugins/installed_plugins.json /home/vscode/.claude/plugins/installed_plugins.json
COPY --chown=vscode:vscode build-context/claude-plugins/known_marketplaces.json /home/vscode/.claude/plugins/known_marketplaces.json

# Rebuild any plugin that has a package.json (handles understand-anything's
# Vite-based dashboard with native deps). Skip silently if the layout doesn't
# match expectations — better to ship the plugins as inert directories than
# fail the whole build.
RUN set -e \
 && for d in /home/vscode/.claude/plugins/cache/*/*/*/ ; do \
      if [ -f "$d/package.json" ]; then \
        echo "Rebuilding $d for $TARGETARCH" ; \
        ( cd "$d" && pnpm install --frozen-lockfile 2>/dev/null \
            || pnpm install 2>/dev/null \
            || npm install 2>/dev/null \
            || echo "  (no package manager succeeded; continuing)" ) ; \
      fi ; \
      if [ -f "$d/packages/dashboard/package.json" ]; then \
        ( cd "$d/packages/dashboard" && pnpm install --frozen-lockfile 2>/dev/null \
            || pnpm install 2>/dev/null \
            || echo "  (dashboard install skipped)" ) ; \
      fi ; \
    done

# Backup plugin config at /etc/skel for troubleshooting recovery
USER root
RUN mkdir -p /etc/skel/.claude/plugins \
 && cp /home/vscode/.claude/plugins/*.json /etc/skel/.claude/plugins/ 2>/dev/null || true
USER vscode

# ---- Layer 7: Playwright Chromium (used by Demo 2 Phase 5 VERIFY) ----
RUN npx --yes playwright@latest install chromium \
 && ls $HOME/.cache/ms-playwright/chromium-*/chrome-linux*/chrome

# ---- Layer 8: Make CARGO_HOME writable by vscode ----
# rustup installed as root in Layer 4; vscode needs write access so post-create's
# `cargo fetch` (inside the cloned codex repo on the workspace mount) can populate
# /usr/local/cargo/{registry,git}/ caches.
USER root
RUN chown -R vscode:vscode /usr/local/cargo
USER vscode

# Note: demo repos (codex, opencode, twenty) are NOT baked into this image.
# They are cloned into ${workspaceFolder}/workshop/ at container creation by
# .devcontainer/post-create.sh, so participant edits + git state persist on the
# host filesystem across container rebuilds.

# ---- Layer 9: Finalize ----
USER root
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
USER vscode

WORKDIR /home/vscode

CMD ["bash"]
