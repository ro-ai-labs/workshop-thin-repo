# Demo 1 — Live Architecture Review: Codex (Rust) + opencode (TypeScript)

Target repos:
- Pane A: `~/workshop/codex`
- Pane B: `~/workshop/opencode`
- Pane C: `~/workshop/` (used for live plugin install in P4)

---

## Pre-flight — install required plugins

One-time per container; persisted by the `itss-workshop-plugins` named volume.

```
/plugin marketplace add anthropics/claude-plugins-official
/plugin marketplace add Lum1104/Understand-Anything
/plugin install superpowers@claude-plugins-official
/plugin install plugin-dev@claude-plugins-official
/plugin install understand-anything@understand-anything
```

`hookify` is **not** installed here — it gets installed live in P4.

Verify:

```
/plugin list
```

---

## Setup

Two terminal panes with a running `claude` session each:

```bash
# Pane A
cd ~/workshop/codex
claude

# Pane B
cd ~/workshop/opencode
claude
```

---

## P1 — Side-by-side architecture review

Paste in **both** Pane A and Pane B:

```
Explain the architecture of this codebase. Map (a) the agent loop, (b) tool definitions and registration, (c) permission/approval logic, (d) sandbox or isolation mechanism, (e) plugin/extension model. Cite file:line for each finding.
```

Recovery — output too shallow:

```
Look at the plugins/ directory and explain the plugin manifest structure.
```

Recovery — permission system not found:

```
Search for files related to permission checking, tool approval, or settings schema. Then explain how the Allow/Ask/Deny model is configured.
```

---

## P2 — Architecture HTML

Both prompts ask the agent to map the **8 named primitives of an agentic
coding runtime** (open set):

1. **context window** — turn/state assembly, what gets in, what gets evicted
2. **tools** — definitions, registration, invocation
3. **permissions / sandbox** — Allow/Ask/Deny model + sandbox mechanism (Seatbelt / bubblewrap / restricted tokens / path validation, etc.)
4. **skills** — the structured-prompt unit, where they live, how they load
5. **plugins** — extension model, manifest schema, install path
6. **MCP** — Model Context Protocol client, server registration, transport types
7. **memory** — AGENTS.md / CLAUDE.md (always-loaded instruction file at repo root)
8. **subagents** — dispatch pattern that spawns a fresh agent instance with bounded prompt and isolated context

Pane A (Codex):

```
Generate an interactive HTML architecture page at `./../demo-examples/codex-architecture.html`.

Map this repo's implementation of the 8 named primitives of an agentic coding runtime:
1. context window — how the conversation/turn state is assembled, what gets in, what gets evicted
2. tools — definitions, registration, invocation
3. permissions / sandbox — Allow/Ask/Deny model AND the sandbox mechanism (Seatbelt / bubblewrap / restricted tokens / path validation)
4. skills — the structured-prompt unit, where they live, how they're loaded
5. plugins — extension model, manifest schema, install path
6. MCP — Model Context Protocol client, server registration, transport types
7. memory — AGENTS.md / CLAUDE.md handling (the always-loaded instruction file at repo root)
8. subagents — dispatch pattern that spawns a fresh agent instance with bounded prompt and isolated context

For each primitive, include clickable file:// links to actual source files in this repo with file:line precision.

Visual layout:
- Top nav with anchor links to all 8 primitives
- One <section> per primitive with file:line citations as inline file:// hrefs
- Simple HTML + CSS, no external dependencies, no JS frameworks
- Self-contained, openable directly in a browser

The 8 primitives are an open set — surface anything additional that emerges from the codebase (agent loop, hooks, etc.) in an "Additional" section at the bottom.
```

Pane B (opencode):

```
Generate an interactive HTML architecture page at `./../demo-examples/opencode-architecture.html`.

Map this repo's implementation of the 8 named primitives of an agentic coding runtime:
1. context window — how the conversation/turn state is assembled, what gets in, what gets evicted
2. tools — definitions, registration, invocation
3. permissions / sandbox — Allow/Ask/Deny model AND the sandbox mechanism (Seatbelt / bubblewrap / restricted tokens / path validation)
4. skills — the structured-prompt unit, where they live, how they're loaded
5. plugins — extension model, manifest schema, install path
6. MCP — Model Context Protocol client, server registration, transport types
7. memory — AGENTS.md / CLAUDE.md handling (the always-loaded instruction file at repo root)
8. subagents — dispatch pattern that spawns a fresh agent instance with bounded prompt and isolated context

For each primitive, include clickable file:// links to actual source files in this repo with file:line precision.

Visual layout:
- Top nav with anchor links to all 8 primitives
- One <section> per primitive with file:line citations as inline file:// hrefs
- Simple HTML + CSS, no external dependencies, no JS frameworks
- Self-contained, openable directly in a browser

The 8 primitives are an open set — surface anything additional that emerges from the codebase (agent loop, hooks, etc.) in an "Additional" section at the bottom.
```

### Generic version (run on any repo — Monday take-home)

This is the canonical take-home prompt — generic scope decomposition, parallel
subagents, validation pass. Use it on any repo (not just agentic-coding runtimes).
The Pane A/B prompts above are the workshop-specific variants that lock the
8-primitive shape for the side-by-side reveal; this one adapts to whatever
codebase you point it at.

Set a one-liner goal first (helpful for the agent):

```
/goal Map this repo's architecture into an interactive HTML using parallel subagents, with file:line citations for every claim and clickable links to the actual source files.
```

Then paste the prompt body:

```
Produce an interactive HTML architecture map of this repository.
Parallel subagent exploration, clickable file:// links to every cited source location, and a validation pass at the end.
APPROACH (orchestrator → subagents → orchestrator):
1. ORCHESTRATOR FIRST PASS.
   Read the top-level directory listing, the README, and the primary
   package manifest you find (package.json, Cargo.toml, pyproject.toml,
   go.mod, pom.xml, build.gradle, etc.). Identify primary language(s),
   framework(s), license, and the high-level shape of the codebase.
2. DECOMPOSE INTO 3–5 EXPLORATION SCOPES.
   Pick what fits THIS repo. Default scopes (adjust based on what you
   actually see):
     - Entry points + bootstrap (CLI mains, server starts, top-level scripts)
     - Core business logic / domain modules
     - Data layer / persistence / state management
     - Integration surfaces (API clients, external services, MCP / tool
       integrations, message queues)
     - Infrastructure (build, test, deployment, CI, IaC)
   If the repo is small (<5k LOC) or single-purpose (a CLI tool, a
   library), use 2–3 scopes instead of 5. If it's a monorepo, use one
   scope per package or one per service.
3. DISPATCH ONE SUBAGENT PER SCOPE via the Task tool.
   Each subagent gets:
     - Scope name + one-sentence purpose
     - 1–3 starting directories or files
     - Output contract: structured markdown with a table per module -
       "Module | Purpose (one sentence) | Key files (file:line) |
       Notable patterns | Open questions"
     - Quality bar: every claim has a file:line citation. No claims
       without citations. Don't invent paths. If something is unclear,
       flag it as an Open Question rather than guessing.
4. SYNTHESIZE WHEN ALL RETURN.
   - Resolve overlaps: if two subagents touched the same file, prefer
     the more specific one.
   - Note any disagreements as Open Questions.
   - Build a single coherent architecture model.
5. GENERATE INTERACTIVE HTML AT ./docs/architecture-map.html.
   Required structure:
   - Header block: repo name (from git remote or README), primary
     language(s), license (read from LICENSE if present), generation
     timestamp.
   - One section per scope, color-coded with distinct backgrounds.
   - Per module: name, one-line purpose, key files as clickable
     `file://` links using ABSOLUTE paths to this repo (use the
     current working directory's absolute path as the prefix).
   - Cross-cutting patterns section (if multiple subagents observed
     the same pattern across scopes - e.g., dependency injection style,
     async pattern, error-handling convention).
   - Footer: list of top-level directories/files NOT covered (so the
     reader knows what's uncharted), plus all Open Questions surfaced
     by subagents.
   - Simple HTML + CSS, no external dependencies, no JS frameworks.
     Must open standalone in a browser.
6. VALIDATE EVERY file:// LINK.
   Walk the generated HTML, extract every `href="file:///..."`,
   confirm the target exists on disk. Fix or remove any broken link.
   Report the total link count and resolve rate (e.g., "73/73 links
   resolve, 100%").
CONSTRAINTS:
- Read-only on the repo. Don't modify any source files.
- If the repo is >100k LOC, scope each subagent to a specific
  subdirectory rather than a whole concern. Otherwise the subagents
  return too much.
- If the repo has no recognizable structure (e.g., research code,
  abandoned experiments), say so and stop. Don't invent architecture.
- Use standard file:// links: absolute paths, no trailing
  punctuation, no spaces (URL-encode if needed). Note in the
  generated HTML footer that Chrome (and Edge) block file:// → file://
  nav by default; launch with --allow-file-access-from-files and an
  isolated --user-data-dir profile to enable clickthrough.
```

**Knobs worth tuning per use case** (search/replace in the prompt above):

| Knob | Default | When to change |
|---|---|---|
| Output filename | `./docs/architecture-map.html` | Multiple maps in same repo → `./docs/architecture-<scope>.html`; team doesn't keep `/docs` → drop into repo root |
| Scope count | 3–5 subagents | Small CLI / library: 2–3. Big monorepo: one per package |
| Default scopes | Entry / business logic / data / integrations / infrastructure | Replace with stack-specific scopes (e.g., frontend / backend / shared / build for a typical SPA) |
| LOC threshold | 100k | Lower if runtime is constrained; raise on a beefy machine |

**Typical numbers** (from workshop simulation on real repos):
- Codex CLI (Rust, dozens of crates): 554-line HTML, 73 file:// links, 100% resolve
- anomalyco/opencode (TypeScript monorepo): 775-line HTML, 100 file:// links, 99% resolve

Wallclock: ~8–10 min for average-sized repos, longer for monorepos.

Live generation takes ~8–10 min. Open pre-rehearsed fallbacks instead:

```bash
chrome-workshop ./workshop/demo-examples/demo-codex-architecture.html
chrome-workshop ./workshop/demo-examples/demo-opencode-architecture.html
```

---

## P2.5 — Understand-Anything dashboard

Inside the existing Pane A `claude` session:

```
/plugin marketplace add Lum1104/Understand-Anything
/plugin install understand-anything@understand-anything
/reload-plugins
/understand-dashboard
```

Pre-generated the night before via `/understand` on `./workshop/codex`.

---

## P3 — Walk-through (no new prompt)

Side-by-side narration of primitives visible in each diagram. No new Claude prompt.

---

## P4 — Install Hookify live

Open Pane C:

```bash
cd ./workshop
claude
```

Inside the `claude` session:

```
/plugin install hookify@claude-plugins-official
```

---

## P5 — MCP name-drop

Verbal callout only. No prompt.

---

## P6 — Demo 1 Part 2: scaffold a marketplace + a plugin derived from P2

The demo plugin wraps the **P2 HTML-architecture prompt** as a reusable skill,
so anyone in the org can run it in any repo without retyping the prompt.

### P6.1 — Live prompt in Pane C

```
Use the plugin-dev:create-plugin skill to scaffold a Claude Code plugin
MARKETPLACE at ~/workshop/itss-plugins/ that ITSS would own internally.
Include:
- .claude-plugin-marketplace.json (marketplace manifest, name "itss-plugins")
- plugins/ directory
- One plugin: plugins/architecture-html/ with .claude-plugin/plugin.json +
  skills/architecture-html/SKILL.md
- The skill should wrap exactly the live prompt we ran in P2: generate
  an interactive HTML architecture page at ./demo-examples/<repo>-architecture.html,
  visualize agent loop + tools + permissions + sandbox + plugins with
  clickable file:// links to actual source files, simple HTML + CSS,
  no external dependencies, self-contained.
- README.md explaining how to /plugin marketplace add + /plugin install
Show the resulting file tree when done.
```

### P6.2 — Bootstrap fallback (paste verbatim if the live prompt stalls)

```bash
mkdir -p ~/workshop/itss-plugins/plugins/architecture-html/.claude-plugin
mkdir -p ~/workshop/itss-plugins/plugins/architecture-html/skills/architecture-html

cat > ~/workshop/itss-plugins/.claude-plugin-marketplace.json <<'EOF'
{
  "name": "itss-plugins",
  "description": "Internal marketplace for ITSS",
  "owner": "itss",
  "plugins": [
    {
      "name": "architecture-html",
      "source": "./plugins/architecture-html",
      "description": "Generate an interactive HTML architecture page for any codebase"
    }
  ]
}
EOF

cat > ~/workshop/itss-plugins/plugins/architecture-html/.claude-plugin/plugin.json <<'EOF'
{
  "name": "architecture-html",
  "version": "0.1.0",
  "description": "Generate an interactive HTML architecture page for any codebase"
}
EOF

cat > ~/workshop/itss-plugins/plugins/architecture-html/skills/architecture-html/SKILL.md <<'EOF'
---
name: architecture-html
description: Use when the user asks to generate an HTML architecture page, visualize a codebase's modules in a browser, or produce a clickable file:// architecture diagram for the current repo
---

# architecture-html

Generate an interactive HTML architecture page for the current repo, mapping
the 8 named primitives of an agentic coding runtime (open set).

## Output

Write to `./demo-examples/<repo-name>-architecture.html` (create the directory
if missing). `<repo-name>` comes from `package.json`, `Cargo.toml`,
`pyproject.toml`, or the basename of `git remote get-url origin`.

## The 8 primitives to map

1. **context window** — turn/state assembly, what gets in, what gets evicted
2. **tools** — definitions, registration, invocation
3. **permissions / sandbox** — Allow/Ask/Deny model AND sandbox mechanism (Seatbelt / bubblewrap / restricted tokens / path validation)
4. **skills** — the structured-prompt unit, where they live, how they're loaded
5. **plugins** — extension model, manifest schema, install path
6. **MCP** — Model Context Protocol client, server registration, transport types
7. **memory** — AGENTS.md / CLAUDE.md (always-loaded instruction file at repo root)
8. **subagents** — dispatch pattern that spawns a fresh agent instance with bounded prompt and isolated context

If the current repo is NOT an agentic coding runtime, map whichever primitives
apply and add a "Not present in this codebase" line for the ones that don't.

## Constraints

- Simple HTML + CSS only — no external dependencies, no JS frameworks.
- Self-contained: openable directly in a browser via `file://`.
- Top nav with anchor links to all 8 primitives.
- One `<section>` per primitive with `file:line` citations as inline `file://` hrefs.

## Process

1. Identify the repo name (sources above).
2. Scan `src/`, `packages/`, `codex-rs/`, or whatever the repo's top-level
   source layout is, for each of the 8 primitives.
3. Map each finding to `file:line` citations.
4. Emit the HTML with one `<section>` per primitive, top-nav anchor links,
   inline `file://` `href`s on every citation.
5. Add an "Additional" section at the bottom for anything beyond the 8
   (agent loop, hooks, etc.) that emerges from the codebase.
EOF

cat > ~/workshop/itss-plugins/README.md <<'EOF'
# ITSS Plugins

Internal Claude Code marketplace.

## Install

```
/plugin marketplace add ~/workshop/itss-plugins
/plugin install architecture-html@itss-plugins
```

## Plugins

- **architecture-html** — generate an interactive HTML architecture page for
  any codebase (clickable `file://` links to source).

## Publish

A marketplace is a git repo with a `.claude-plugin-marketplace.json` manifest.
Host this directory on your internal git, and your team can `/plugin
marketplace add <git-url>` to install from it.
EOF
```

### P6.3 — Reveal

```bash
tree ~/workshop/itss-plugins/
```

### P6.4 — Install handshake (optional)

Inside the Pane C `claude` session:

```
/plugin marketplace add ~/workshop/itss-plugins
/plugin install architecture-html@itss-plugins
/reload-plugins
```

Run the skill on a different repo to prove it generalizes:

```bash
cd ~/workshop/opencode
claude
```

In the `claude` session:

```
Use the architecture-html skill to produce the page for this repo.
```

---

## Recovery references

| Failure | Fallback |
|---|---|
| P2 generation too slow | Open the pre-rehearsed HTML fallbacks in `~/workshop/drive-share/` |
| P2.5 dashboard fails to open | Skip P2.5; P2 fallback HTMLs remain on screen |
| P6.1 produces no file writes in 30 sec | Play `~/workshop/drive-share/itss-marketplace-scaffold.mp4` |
| P6.1 fallback video unavailable | Open `~/workshop/drive-share/itss-marketplace-tree.png`, walk the tree |
