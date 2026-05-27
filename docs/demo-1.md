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
Generate an interactive HTML architecture page at ./demo-examples/codex-architecture.html. Visualize Codex's modules (agent loop, tools, permissions, sandbox, plugins) with clickable file:// links to the actual source files in this repo. Use simple HTML + CSS, no external dependencies. Self-contained, openable in a browser.
```

Pane B (opencode):

```
Generate an interactive HTML architecture page at ./demo-examples/opencode-architecture.html. Visualize opencode's modules (agent loop, tools, permissions, sandbox, plugins) with clickable file:// links to the actual source files in this repo. Use simple HTML + CSS, no external dependencies. Self-contained, openable in a browser.
```

Live generation takes ~8–10 min. Open pre-rehearsed fallbacks instead:

```bash
chrome-workshop ~/workshop/drive-share/demo-codex-architecture.html
chrome-workshop ~/workshop/drive-share/demo-opencode-architecture.html
```

---

## P2.5 — Understand-Anything dashboard

Inside the existing Pane A `claude` session:

```
/understand-dashboard
```

Pre-generated the night before via `/understand` on `~/workshop/codex`.

---

## P3 — Walk-through (no new prompt)

Side-by-side narration of primitives visible in each diagram. No new Claude prompt.

---

## P4 — Install Hookify live

Open Pane C:

```bash
cd ~/workshop
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

## P6 — Demo 1 Part 2: scaffold a marketplace

### P6.1 — Live prompt in Pane C

```
Use the plugin-dev:create-plugin skill to scaffold a Claude Code plugin
MARKETPLACE at ~/workshop/itss-plugins/ that ITSS would own internally.
Include:
- .claude-plugin-marketplace.json (marketplace manifest)
- plugins/ directory
- One sample plugin: plugins/aml-pattern-checks/ with plugin.json +
  skills/aml-pattern-checks/SKILL.md stub (purpose: detect structuring
  patterns in transaction lists; scaffold only, no implementation)
- README.md explaining how to publish + install from this marketplace
Show the resulting file tree when done.
```

Plain-prompt fallback (use only if `plugin-dev:create-plugin` insists on interactive Q&A):

```
Scaffold a Claude Code plugin MARKETPLACE at ~/workshop/itss-plugins/ that
ITSS would own internally. Reference the plugin-dev plugin (already installed
from claude-plugins-official) for the exact file layout and manifest schema.
Files to create:
- .claude-plugin-marketplace.json (the marketplace manifest — name "itss-plugins",
  one entry pointing at plugins/aml-pattern-checks/)
- plugins/aml-pattern-checks/.claude-plugin/plugin.json
- plugins/aml-pattern-checks/skills/aml-pattern-checks/SKILL.md (frontmatter
  + 3-sentence purpose: detect structuring patterns in transaction lists;
  scaffold only, no implementation)
- README.md explaining how to /plugin marketplace add this directory and
  /plugin install aml-pattern-checks@itss-plugins
Show the resulting file tree with `tree ~/workshop/itss-plugins/` when done.
```

### P6.2 — Reveal

```bash
tree ~/workshop/itss-plugins/
```

### P6.3 — Install handshake (optional)

Inside the Pane C `claude` session:

```
/plugin marketplace add ~/workshop/itss-plugins
```

---

## Recovery references

| Failure | Fallback |
|---|---|
| P2 generation too slow | Open the pre-rehearsed HTML fallbacks in `~/workshop/drive-share/` |
| P2.5 dashboard fails to open | Skip P2.5; P2 fallback HTMLs remain on screen |
| P6.1 produces no file writes in 30 sec | Play `~/workshop/drive-share/itss-marketplace-scaffold.mp4` |
| P6.1 fallback video unavailable | Open `~/workshop/drive-share/itss-marketplace-tree.png`, walk the tree |
