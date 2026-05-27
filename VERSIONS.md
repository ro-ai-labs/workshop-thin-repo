# VERSIONS.md
# All pinned versions for this devcontainer build.
# Update at each rebuild; commit alongside Dockerfile changes.

source-of-truth: docs/superpowers/specs/2026-05-27-itss-workshop-devcontainer-design.md

# Demo repos (cloned at container creation by .devcontainer/post-create.sh
# from .devcontainer/versions.env — see that file for the machine-readable form).
# Not baked into the image; live on the workspace bind-mount for persistence.
codex:
  repo: https://github.com/ro-ai-labs/codex.git
  sha:  5349d134ee0e4e82d580d45080bbf42cd0caeb5b
  branch: demo
opencode:
  repo: https://github.com/ro-ai-labs/opencode.git
  sha:  8e4b24178a411a78011b6024212422d9a98c6375
  branch: demo
twenty:
  repo: https://github.com/ro-ai-labs/twenty.git
  sha:  ca96c78a81331a5d14b78002e325c5800dac2c3c
  branch: demo

# (Demo 3 / spring-boot-pr-demo dropped 2026-05-27.)

# Toolchains
node:  24.5.0
yarn:  4.13.0
bun:   1.3.14
pnpm:  latest (Corepack)
rust:  1.93.0 (clippy, rustfmt, rust-src)

# Claude
claude-code-cli: latest-stable-at-build (npm install -g @anthropic-ai/claude-code)
# Plugins are NOT baked into the image. Install manually in-container via
# `/plugin marketplace add` + `/plugin add`. Suggested set for the workshop:
plugins-suggested:
  - hookify @ claude-plugins-official
  - security-guidance @ claude-plugins-official
  - superpowers @ claude-plugins-official
  - pr-review-toolkit @ claude-plugins-official
  - commit-commands @ claude-plugins-official
  - plugin-dev @ claude-plugins-official
  - understand-anything @ Lum1104/Understand-Anything

# Image — built locally by each participant from .devcontainer/Dockerfile.
# No container registry, no pull, no auth tokens.
local-tag: itss-workshop:local
platforms: linux/amd64   # x86_64 only. Apple Silicon / ARM PCs follow docs/HOST_SETUP.md
