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

# ---- Layer 5: docker-compose v1 shim ----
# Deliverables docs sometimes say "docker-compose up" while modern is
# "docker compose". DinD provides v2. Claude Code CLI moved to a vscode-side
# step further down (it installs to $HOME/.local/, so must run as vscode).
RUN printf '#!/usr/bin/env bash\nexec docker compose "$@"\n' > /usr/local/bin/docker-compose \
 && chmod +x /usr/local/bin/docker-compose

# Ensure vscode user owns .cache for npm/playwright/bun installs
RUN mkdir -p /home/vscode/.cache /home/vscode/.bun \
 && chown -R vscode:vscode /home/vscode

USER vscode
WORKDIR /home/vscode

# Pre-cache Yarn 4 + pnpm in vscode's Corepack store. The root-side
# `corepack prepare --activate` in Layer 2 only populated /root/.cache, so
# without this step Twenty's first `yarn install` would download Yarn 4
# fresh on workshop wifi.
RUN corepack prepare yarn@4.13.0 --activate \
 && corepack prepare pnpm@latest --activate

# ---- nvm + Node 24.5.0 (Twenty's local-setup docs use `nvm install`) ----
# Twenty's .nvmrc pins 24.5.0 exactly. The apt-installed system Node 24.x
# (Layer 2) already satisfies engines: ^24.5.0, but having nvm available with
# 24.5.0 pre-cached lets participants follow Twenty's docs verbatim and avoids
# any network hit at demo time. Installs as vscode user — nvm lives in $HOME.
ENV NVM_DIR=/home/vscode/.nvm
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash \
 && bash -c '. "$NVM_DIR/nvm.sh" && nvm install 24.5.0 && nvm alias default 24.5.0 && nvm cache clear' \
 && bash -c '. "$NVM_DIR/nvm.sh" && nvm --version && node --version'

# ---- Claude Code CLI (native installer from claude.ai) ----
# Anthropic's current install channel installs to $HOME/.local/share/claude
# with a symlink at $HOME/.local/bin/claude. Replaces the npm distribution
# (`npm i -g @anthropic-ai/claude-code`), which the CLI itself prompts users
# to migrate away from. Runs as vscode so files land in the right home.
ENV PATH="/home/vscode/.local/bin:${PATH}"
RUN curl -fsSL https://claude.ai/install.sh | bash \
 && claude --version

# Plugins are NOT baked. Participants install them at workshop time via
# `claude /plugin add <name>@claude-plugins-official` (or the equivalent inside
# a `claude` session). The named volume mounted at /home/vscode/.claude/plugins
# persists those installs across container rebuilds — see devcontainer.json.
# Pre-create the dir so claude doesn't trip over a missing path on first run.
USER root
RUN mkdir -p /home/vscode/.claude/plugins \
 && chown -R vscode:vscode /home/vscode/.claude
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
