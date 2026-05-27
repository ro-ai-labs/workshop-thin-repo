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

Pane A (Codex):

```
Generate an interactive HTML architecture page at `./../demo-examples/codex-architecture.html`. Visualize Codex's modules (agent loop, tools, permissions, sandbox, plugins) with clickable file:// links to the actual source files in this repo. Use simple HTML + CSS, no external dependencies. Self-contained, openable in a browser.
```

Pane B (opencode):

```
Generate an interactive HTML architecture page at `./../demo-examples/opencode-architecture.html`. Visualize opencode's modules (agent loop, tools, permissions, sandbox, plugins) with clickable file:// links to the actual source files in this repo. Use simple HTML + CSS, no external dependencies. Self-contained, openable in a browser.
```

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

Generate an interactive HTML architecture page for the current repo.

## Output

Write to `./demo-examples/<repo-name>-architecture.html` (create the directory
if missing). `<repo-name>` comes from `package.json`, `Cargo.toml`,
`pyproject.toml`, or the basename of the repo's `git remote get-url origin`.

## Content

Visualize the repo's modules in five sections:

1. Agent loop
2. Tool definitions and registration
3. Permission / approval logic
4. Sandbox or isolation mechanism
5. Plugin / extension model

For each module, include clickable `file://` links to actual source files in
this repo with `file:line` precision where useful.

## Constraints

- Simple HTML + CSS only — no external dependencies, no JS frameworks.
- Self-contained: openable directly in a browser via `file://`.
- Use anchor links between sections for in-page navigation.

## Process

1. Identify the repo name (sources above).
2. Scan `src/`, `packages/`, `codex-rs/`, or whatever the repo's top-level
   source layout is, for the five categories above.
3. Map each finding to `file:line` citations.
4. Emit the HTML with one `<section>` per category, anchor links in a top
   nav, and inline `file://` `href`s for every citation.
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
