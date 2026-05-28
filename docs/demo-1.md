# Demo 1 - Live Architecture Review: Codex (Rust) + opencode (TypeScript)

Target repos:
- Pane A: `./workshop/codex`
- Pane B: `./workshop/opencode`
- Pane C: `./workshop/` (used for live plugin install in P4)

---

```
/tui fullscreen
/

## Pre-flight - install required plugins

One-time per container; persisted by the `itss-workshop-plugins` named volume.

`claude-plugins-official` ships built-in - no `marketplace add` needed.
Only the third-party `Lum1104/Understand-Anything` requires an explicit
`marketplace add`.

```
/plugin marketplace add Lum1104/Understand-Anything
/plugin install superpowers@claude-plugins-official
/plugin install plugin-dev@claude-plugins-official
/plugin install security-guidance@claude-plugins-official
/plugin install pr-review-toolkit@claude-plugins-official
/plugin install understand-anything@understand-anything
```

`hookify` is **not** installed here - it gets installed live in P4. If
hookify is already installed from a prior container session, uninstall it
first (`/plugin uninstall hookify`) so the P4 install is a real live moment.

Verify:

```
/plugin list
```

---

## Setup

Two terminal panes with a running `claude` session each:

```bash
# Pane A
cd ./workshop/codex
claude

# Pane B
cd ./workshop/opencode
claude
```

---

## P1 - Side-by-side architecture review

Paste in **both** Pane A and Pane B:

```
Explain the architecture of this codebase. Map (a) the agent loop, (b) tool definitions and registration, (c) permission/approval logic, (d) sandbox or isolation mechanism, (e) plugin/extension model. Cite file:line for each finding.
```

Recovery - output too shallow:

```
Look at the plugins/ directory and explain the plugin manifest structure.
```

Recovery - permission system not found:

```
Search for files related to permission checking, tool approval, or settings schema. Then explain how the Allow/Ask/Deny model is configured.
```

---

## P2 - Architecture HTML

Both prompts ask the agent to map the **8 named primitives of an agentic
coding runtime** (open set):

1. **context window** - turn/state assembly, what gets in, what gets evicted
2. **tools** - definitions, registration, invocation
3. **permissions / sandbox** - Allow/Ask/Deny model + sandbox mechanism (Seatbelt / bubblewrap / restricted tokens / path validation, etc.)
4. **skills** - the structured-prompt unit, where they live, how they load
5. **plugins** - extension model, manifest schema, install path
6. **MCP** - Model Context Protocol client, server registration, transport types
7. **memory** - AGENTS.md / CLAUDE.md (always-loaded instruction file at repo root)
8. **subagents** - dispatch pattern that spawns a fresh agent instance with bounded prompt and isolated context

Pane A (Codex):

```
Generate an interactive HTML architecture page at `./../demo-examples/codex-architecture.html`.

Map this repo's implementation of the 8 named primitives of an agentic coding runtime:
1. context window - how the conversation/turn state is assembled, what gets in, what gets evicted
2. tools - definitions, registration, invocation
3. permissions / sandbox - Allow/Ask/Deny model AND the sandbox mechanism (Seatbelt / bubblewrap / restricted tokens / path validation)
4. skills - the structured-prompt unit, where they live, how they're loaded
5. plugins - extension model, manifest schema, install path
6. MCP - Model Context Protocol client, server registration, transport types
7. memory - AGENTS.md / CLAUDE.md handling (the always-loaded instruction file at repo root)
8. subagents - dispatch pattern that spawns a fresh agent instance with bounded prompt and isolated context

For each primitive, include clickable file:// links to actual source files in this repo with file:line precision.

Visual layout:
- Top nav with anchor links to all 8 primitives
- One <section> per primitive with file:line citations as inline file:// hrefs
- Simple HTML + CSS, no external dependencies, no JS frameworks
- Self-contained, openable directly in a browser

The 8 primitives are an open set - surface anything additional that emerges from the codebase (agent loop, hooks, etc.) in an "Additional" section at the bottom.
```

Pane B (opencode):

```
Generate an interactive HTML architecture page at `./../demo-examples/opencode-architecture.html`.

Map this repo's implementation of the 8 named primitives of an agentic coding runtime:
1. context window - how the conversation/turn state is assembled, what gets in, what gets evicted
2. tools - definitions, registration, invocation
3. permissions / sandbox - Allow/Ask/Deny model AND the sandbox mechanism (Seatbelt / bubblewrap / restricted tokens / path validation)
4. skills - the structured-prompt unit, where they live, how they're loaded
5. plugins - extension model, manifest schema, install path
6. MCP - Model Context Protocol client, server registration, transport types
7. memory - AGENTS.md / CLAUDE.md handling (the always-loaded instruction file at repo root)
8. subagents - dispatch pattern that spawns a fresh agent instance with bounded prompt and isolated context

For each primitive, include clickable file:// links to actual source files in this repo with file:line precision.

Visual layout:
- Top nav with anchor links to all 8 primitives
- One <section> per primitive with file:line citations as inline file:// hrefs
- Simple HTML + CSS, no external dependencies, no JS frameworks
- Self-contained, openable directly in a browser

The 8 primitives are an open set - surface anything additional that emerges from the codebase (agent loop, hooks, etc.) in an "Additional" section at the bottom.
```

### Generic version (run on any repo - Monday take-home)

This is the canonical take-home prompt - generic scope decomposition, parallel
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
chrome-workshop ./workshop/drive-share/demo-codex-architecture.html
chrome-workshop ./workshop/drive-share/demo-opencode-architecture.html
```

---

## P2.5 - Understand-Anything dashboard

Inside the existing Pane A `claude` session (`understand-anything` was
installed in Pre-flight; just open the pre-generated dashboard):

```
/understand-dashboard
```

Pre-generated the night before via `/understand` on `./workshop/codex`.

---

## P3 - Walk-through (no new prompt)

Side-by-side narration of primitives visible in each diagram. No new Claude prompt.

---

## P4 - Hookify: install, trigger, author a custom rule

Open Pane C:

```bash
cd ./workshop
claude
```

### P4.1 - Install

Inside the `claude` session:

```
/plugin install hookify@claude-plugins-official
```

Rules are active immediately - no restart or reload step needed.

### P4.2 - Inspect the bundled rules

Hookify ships with example rules - markdown files with YAML frontmatter,
versionable in git, readable by humans. The plugin loads them from its own
`examples/` directory and from `.claude/hookify.<rule-name>.local.md` in the
current repo.

```
/hookify:list
```

Open one of the bundled rules in the editor to show what a rule IS:

```bash
cat ~/.claude/plugins/cache/claude-plugins-official/hookify/*/examples/dangerous-rm.local.md
```

The rule body:

```markdown
---
name: block-dangerous-rm
enabled: true
event: bash
pattern: rm\s+-rf
action: block
---

⚠️ **Dangerous rm command detected!**

This command could delete important files. Please:
- Verify the path is correct
- Consider using a safer approach
- Make sure you have backups
```

Rule fields:
- **event:** `bash` | `file` | `stop` | `prompt` | `all` - which hook trigger fires the rule
- **pattern:** regex matched against the command (`bash`), the new file content (`file`), the transcript (`stop`), or the prompt (`prompt`)
- **action:** `warn` (show message, allow) | `block` (prevent the operation)

### P4.3 - Trigger the dangerous-rm rule

In the `claude` session, ask Claude to run a destructive command:

```
Run this for me: rm -rf /tmp/hookify-demo-target
```

The hookify rule blocks the bash call and surfaces the rule's message to
Claude. Claude reports back that the operation was blocked.

### P4.4 - Author a new rule live: "test-first for components"

The frontend-TDD pattern the workshop teaches needs a guardrail. Hookify
can't see git's staged-files state from a bash event (the `command` field
only has the literal command string), so the closest enforceable rule is at
the **file write**: block the creation of a `.tsx` file whose path doesn't
contain `.test.`. Effect: write the test file first, then the component.
Tighter discipline than "block commit", and it works with the real hookify
schema (`field`s: `file_path / new_text / old_text / content` for file
events; `operator`s: `regex_match / contains / equals / not_contains /
starts_with / ends_with`).

Author the rule via `/hookify` (interactive) - or paste the bootstrap below.

**Live prompt (via interactive `/hookify`):**

```
/hookify Block writing a *.tsx file unless the path also contains .test. - frontend TDD discipline, write the test file first.
```

**Bootstrap fallback** (paste verbatim if the interactive flow stalls):

```bash
mkdir -p .claude
cat > .claude/hookify.test-first-for-tsx.local.md <<'EOF'
---
name: test-first-for-tsx
enabled: true
event: file
action: block
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.tsx$
  - field: file_path
    operator: not_contains
    pattern: .test.
---

🚫 **Test-first rule: write `.test.tsx` before `.tsx`**

Frontend TDD discipline (Demo 2 Phase 5 pattern):
- accessibility-tree selectors, not pixel screenshots
- one test file per component, sibling to the component
- the test file gets written FIRST, then the component

This rule blocks creating a `.tsx` file whose path doesn't contain
`.test.`. To proceed:

1. Create the test first: e.g. `Component.test.tsx`
2. Then create the component: `Component.tsx`
EOF
```

### P4.5 - Verify the new rule loaded

```
/hookify:list
```

The list now shows `test-first-for-tsx` alongside the bundled examples.
Rules are active immediately - no restart needed.

### P4.6 - Trigger the new rule

Ask Claude to create a component without writing the test first:

```
Create src/components/Demo.tsx with a small placeholder component that renders "Hello demo". Don't write a test file.
```

The hookify rule blocks the file write at the tool layer and surfaces the
rule's message. Claude reports back that the operation was blocked.

---

**Why this demo lands:** the rule is a markdown file with YAML
frontmatter. It lives in `.claude/` next to the code. It goes through
PR review like any other code. It's diffable, blameable, revertable. The
team's discipline is committed to the repo, not stored in a wiki nobody reads.

**Other useful rule events to mention** (no need to demo, just name them):
- `event: file` - fires on Edit / Write / MultiEdit. Use for "warn on
  console.log", "block edits to .env*", "require type annotations".
- `event: stop` - fires when the agent tries to stop. Use for "block stop
  if no tests ran this session".
- `event: prompt` - fires on user prompt submission. Use for "warn if the
  prompt looks like a credential paste".

---

## P5 - MCP name-drop

Verbal callout only. No prompt.

---

## P6 - Demo 1 Part 2: scaffold a marketplace + a plugin derived from the generic prompt

The demo plugin wraps the **generic Repo Architecture Mapping prompt** (the
Monday take-home variant from P2 above) as a reusable skill - so anyone in
the org can run it on any repo (legacy or otherwise) without retyping the
multi-line prompt. The P2 Pane A/B variants are workshop-only, locked to
the 8-primitive shape; the productionized plugin uses the generic version
that adapts to whatever codebase it's pointed at.

### P6.1 - Live prompt in Pane C

```
Use the plugin-dev:create-plugin skill to scaffold a Claude Code plugin
MARKETPLACE at ./workshop/itss-plugins/ that ITSS would own internally.
Include:
- .claude-plugin-marketplace.json (marketplace manifest, name "itss-plugins")
- plugins/ directory
- One plugin: plugins/architecture-html/ with .claude-plugin/plugin.json +
  skills/architecture-html/SKILL.md
- The skill should wrap the GENERIC Repo Architecture Mapping prompt from
  this demo (the take-home version, NOT the Codex/opencode 8-primitive
  variant). Its body is:
    * Orchestrator first pass on top-level + README + package manifests
    * Decompose into 3–5 exploration scopes (entry / business logic /
      data layer / integrations / infrastructure - adjusted per repo size)
    * Dispatch one subagent per scope via the Task tool, each returning a
      structured markdown table per module with file:line citations
    * Synthesize, resolve overlaps, build coherent architecture model
    * Generate ./docs/architecture-map.html with header + one section per
      scope + cross-cutting patterns + uncharted footer + open questions
    * Validate every file:// link, report resolve rate
  Constraints: read-only on the repo, simple HTML + CSS, no external deps,
  self-contained openable in a browser, file:// uses absolute paths.
- README.md explaining how to /plugin marketplace add + /plugin install
Show the resulting file tree when done.
```

### P6.2 - Bootstrap fallback (paste verbatim if the live prompt stalls)

```bash
mkdir -p ./workshop/itss-plugins/plugins/architecture-html/.claude-plugin
mkdir -p ./workshop/itss-plugins/plugins/architecture-html/skills/architecture-html

cat > ./workshop/itss-plugins/.claude-plugin-marketplace.json <<'EOF'
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

cat > ./workshop/itss-plugins/plugins/architecture-html/.claude-plugin/plugin.json <<'EOF'
{
  "name": "architecture-html",
  "version": "0.1.0",
  "description": "Generate an interactive HTML architecture page for any codebase"
}
EOF

cat > ./workshop/itss-plugins/plugins/architecture-html/skills/architecture-html/SKILL.md <<'EOF'
---
name: architecture-html
description: Use when the user asks to map a codebase's architecture into an interactive HTML, generate an architecture diagram with clickable file:// links, or produce a Repo Architecture Mapping output for the current repo
---

# architecture-html

Produce an interactive HTML architecture map of the current repository, using
parallel subagents for exploration, with clickable `file://` links to every
cited source location and a validation pass at the end.

This skill is repo-agnostic. It works on any codebase.

## Approach (orchestrator → subagents → orchestrator)

### 1. Orchestrator first pass

Read the top-level directory listing, the README, and the primary package
manifest you find (`package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`,
`pom.xml`, `build.gradle`, etc.). Identify primary language(s), framework(s),
license, and the high-level shape of the codebase.

### 2. Decompose into 3–5 exploration scopes

Pick what fits THIS repo. Default scopes (adjust based on what you actually
see):

- Entry points + bootstrap (CLI mains, server starts, top-level scripts)
- Core business logic / domain modules
- Data layer / persistence / state management
- Integration surfaces (API clients, external services, MCP / tool
  integrations, message queues)
- Infrastructure (build, test, deployment, CI, IaC)

If the repo is small (<5k LOC) or single-purpose (a CLI tool, a library),
use 2–3 scopes instead of 5. If it's a monorepo, use one scope per package
or one per service.

### 3. Dispatch one subagent per scope via the Task tool

Each subagent gets:

- Scope name + one-sentence purpose
- 1–3 starting directories or files
- Output contract: structured markdown with a table per module -
  `Module | Purpose (one sentence) | Key files (file:line) | Notable patterns | Open questions`
- Quality bar: every claim has a file:line citation. No claims without
  citations. Don't invent paths. If something is unclear, flag it as an
  Open Question rather than guessing.

### 4. Synthesize when all return

- Resolve overlaps: if two subagents touched the same file, prefer the more
  specific one.
- Note any disagreements as Open Questions.
- Build a single coherent architecture model.

### 5. Generate interactive HTML at `./docs/architecture-map.html`

Required structure:

- **Header block:** repo name (from git remote or README), primary
  language(s), license (read from `LICENSE` if present), generation
  timestamp.
- **One section per scope**, color-coded with distinct backgrounds.
- **Per module:** name, one-line purpose, key files as clickable `file://`
  links using ABSOLUTE paths to this repo (use the current working
  directory's absolute path as the prefix).
- **Cross-cutting patterns section** - if multiple subagents observed the
  same pattern across scopes (dependency injection style, async pattern,
  error-handling convention).
- **Footer:** list of top-level directories/files NOT covered (so the reader
  knows what's uncharted), plus all Open Questions surfaced by subagents.
- Simple HTML + CSS, no external dependencies, no JS frameworks. Must open
  standalone in a browser.

### 6. Validate every `file://` link

Walk the generated HTML, extract every `href="file:///..."`, confirm the
target exists on disk. Fix or remove any broken link. Report the total link
count and resolve rate (e.g., `73/73 links resolve, 100%`).

## Constraints

- Read-only on the repo. Don't modify any source files.
- If the repo is >100k LOC, scope each subagent to a specific subdirectory
  rather than a whole concern. Otherwise the subagents return too much.
- If the repo has no recognizable structure (e.g., research code, abandoned
  experiments), say so and stop. Don't invent architecture.
- Use standard `file://` links: absolute paths, no trailing punctuation, no
  spaces (URL-encode if needed). Note in the generated HTML footer that
  Chrome (and Edge) block `file://` → `file://` nav by default; launch with
  `--allow-file-access-from-files` and an isolated `--user-data-dir` profile
  to enable clickthrough.

## Output filename

Default: `./docs/architecture-map.html`. Change to `./docs/architecture-<scope>.html`
if generating multiple maps in the same repo, or drop into the repo root if
the team doesn't keep a `/docs` directory.
EOF

cat > ./workshop/itss-plugins/README.md <<'EOF'
# ITSS Plugins

Internal Claude Code marketplace.

## Install

```
/plugin marketplace add ./workshop/itss-plugins
/plugin install architecture-html@itss-plugins
```

## Plugins

- **architecture-html** - generate an interactive HTML architecture page for
  any codebase (clickable `file://` links to source).

## Publish

A marketplace is a git repo with a `.claude-plugin-marketplace.json` manifest.
Host this directory on your internal git, and your team can `/plugin
marketplace add <git-url>` to install from it.
EOF
```

### P6.3 - Reveal

```bash
tree ./workshop/itss-plugins/
```

### P6.4 - Install handshake (optional)

Inside the Pane C `claude` session:

```
/plugin marketplace add ./workshop/itss-plugins
/plugin install architecture-html@itss-plugins
```

Run the skill on a NON-agentic repo to prove it generalizes - Twenty CRM
makes the point cleanly (no agent loop, no subagents, just a regular
TypeScript monorepo):

```bash
cd ./workshop/twenty
claude
```

In the `claude` session:

```
Use the architecture-html skill to produce the page for this repo.
```

Expected: `./docs/architecture-map.html` with sections for entry points,
NestJS server, Vite/React front, GraphQL bridge, Postgres + Redis
infrastructure - read-only, validated `file://` links, no architectural
invention.

---

## Recovery references

| Failure | Fallback |
|---|---|
| P2 generation too slow | Open the pre-rehearsed HTML fallbacks in `./workshop/drive-share/` |
| P2.5 dashboard fails to open | Skip P2.5; P2 fallback HTMLs remain on screen |
| P6.1 produces no file writes in 30 sec | Play `./workshop/drive-share/itss-marketplace-scaffold.mp4` |
| P6.1 fallback video unavailable | Open `./workshop/drive-share/itss-marketplace-tree.png`, walk the tree |
