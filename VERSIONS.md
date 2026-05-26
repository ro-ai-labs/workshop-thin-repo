# VERSIONS.md
# All pinned versions for this devcontainer build.
# Update at each rebuild; commit alongside Dockerfile changes.

source-of-truth: docs/superpowers/specs/2026-05-27-itss-workshop-devcontainer-design.md

# Demo repos (cloned from ro-ai-labs forks)
codex:
  repo: https://github.com/ro-ai-labs/codex.git
  sha:  5349d134ee0e4e82d580d45080bbf42cd0caeb5b
  branch: demo-arch
opencode:
  repo: https://github.com/ro-ai-labs/opencode.git
  sha:  8e4b24178a411a78011b6024212422d9a98c6375
  branch: ""  # OPENCODE_BRANCH not set in /tmp/itss-build-vars.sh; confirm with Mihai
twenty:
  repo: https://github.com/ro-ai-labs/twenty.git
  sha:  ca96c78a81331a5d14b78002e325c5800dac2c3c
  branch: demo
spring-boot-pr-demo:
  generator: deliverables/demo-3-setup/create_demo_repo.sh (idempotent; no SHA)

# Toolchains
node:  24.5.0
yarn:  4.13.0
bun:   1.3.14
pnpm:  latest (Corepack)
rust:  1.93.0 (clippy, rustfmt, rust-src)
java:  Temurin 21
maven: 3.9.x (apt default on Ubuntu 22.04)

# Claude
claude-code-cli: latest-stable-at-build
plugins:
  - hookify @ claude-plugins-official
  - security-guidance @ claude-plugins-official
  - superpowers @ claude-plugins-official
  - pr-review-toolkit @ claude-plugins-official
  - code-review @ claude-plugins-official
  - commit-commands @ claude-plugins-official
  - plugin-dev @ claude-plugins-official
  - understand-anything @ Lum1104/Understand-Anything

# Image
image: ghcr.io/ro-ai-labs/itss-workshop:2026.05.28
platforms: linux/amd64   # x86_64 only. Apple Silicon / ARM PCs follow docs/HOST_SETUP.md
