---
name: architecture-html
description: Use when the user asks to "generate an architecture HTML", "map this repo's architecture", "build an interactive code map", "visualize the agent loop / tools / permissions / sandbox / plugins", or wants a single openable HTML page that documents how a codebase's agentic-runtime primitives are wired together. Produces a self-contained HTML file at ./demo-examples/<repo>-architecture.html with clickable file:// links at file:line precision.
argument-hint: "[optional: comma-separated primitives to focus on; default = full 8-primitive set]"
allowed-tools: Bash, Read, Edit, Write, Agent, AskUserQuestion
---

# Architecture HTML - interactive code map generator

Generate a self-contained, browser-openable HTML architecture page that maps how the current repository implements the named primitives of an agentic coding runtime. Every cited symbol must link to the actual source file with `file://` URLs at `file:line` precision.

## What to produce

A single HTML file at:

```
./demo-examples/<repo>-architecture.html
```

where `<repo>` is the **basename of the current working directory** (e.g. cwd `/workspaces/foo/codex` → `codex-architecture.html`). If `./demo-examples/` does not exist, create it.

## The 8 primitives to map

The page must have one `<section>` per primitive in this order:

1. **context window** - how the conversation/turn state is assembled, what gets in, what gets evicted (compaction / truncation)
2. **tools** - definitions, registration, invocation
3. **permissions / sandbox** - the Allow/Ask/Deny approval model **and** the sandbox mechanism (Seatbelt / bubblewrap / restricted tokens / path validation)
4. **skills** - the structured-prompt unit: where they live, how they're loaded
5. **plugins** - extension model, manifest schema, install path
6. **MCP** - Model Context Protocol client, server registration, transport types
7. **memory** - AGENTS.md / CLAUDE.md handling (the always-loaded instruction file at repo root)
8. **subagents** - dispatch pattern that spawns a fresh agent instance with bounded prompt and isolated context

These 8 are an **open set** - surface anything additional that emerges from the codebase (agent loop, hooks, rollout/trace, observability, etc.) in an **"Additional"** section at the bottom.

If the user passed an arguments string, treat it as a comma-separated *focus list*: still include all 8 sections but expand the named ones with more depth.

## Required visual layout

- Top nav with anchor links to all 8 primitives + Additional section
- One `<section>` per primitive containing:
  - Section title + one-line tagline
  - Prose explanation (1–3 short paragraphs) of how the primitive works in this codebase
  - A citation list - each citation is an `<a href="file:///abs/path#Lxx">` link + a short caption explaining what's at that line
- Cite at least 3 file:line citations per primitive
- Simple HTML + CSS, embedded `<style>` block, **no external dependencies**, **no JS frameworks**
- Self-contained, openable directly in a browser by double-click

## How to execute

Follow these steps in order. Use TodoWrite to track progress.

### Step 1 - orient yourself

- `pwd` to confirm cwd, then `ls` and skim the top-level layout, the README, and the primary manifest (`Cargo.toml` / `package.json` / `pyproject.toml` / `go.mod` / `pom.xml` / etc.).
- Identify primary language, build system, and the rough shape (single-package vs monorepo vs workspace).
- Note the **repo basename** - this is `<repo>` for the output filename.

### Step 2 - dispatch parallel explorers

For each of the 8 primitives, dispatch an Explore subagent to find the implementation. Run them **in parallel** in a single message (multiple Agent tool calls).

Each subagent's brief should:
- Name the primitive and what to look for
- List 1–3 starting directories or files derived from your Step 1 survey
- Ask for: concrete file paths (absolute, starting with the cwd prefix), line numbers of key structs/fns/constants, a one-paragraph explanation of how the primitive is implemented in *this* codebase, and 3–5 most important `file:line` citations
- Require every citation to actually exist on disk (the subagent should `grep` or `Read` to confirm)
- Forbid invented paths - if a primitive isn't present, the subagent must say so explicitly

Add one more subagent for the **"Additional"** section: ask it to surface 4–8 extra agentic-runtime primitives the codebase implements (event hooks, trace/replay, observability, identity, agent graph, code-mode, etc.) with 1-paragraph explanations and citations.

### Step 3 - verify before writing

Before generating the HTML, spot-check the most prominent citations from each subagent:
- Confirm files exist (`test -f`)
- Confirm the cited symbol is at (or very near) the cited line - quick `grep -n` checks
- Watch out for byte-count-as-line-number mistakes from agents; if a "line number" exceeds the file's line count, re-grep for the real position
- If the repo is small (<5k LOC) or single-purpose, drop primitives that genuinely don't exist instead of inventing them - mention their absence in the section's prose

### Step 4 - write the HTML

Write the file to `./demo-examples/<repo>-architecture.html` with:
- Dark theme is fine (matches a code-editor aesthetic). Pick any clean, readable scheme.
- Sticky top nav so anchors stay clickable while scrolling.
- Use absolute paths in `file://` hrefs (start from `/`, not relative). Cwd-derive the prefix from `pwd` output.
- Use `#L<lineno>` fragments (e.g. `file:///abs/path.rs#L42`) so editors / browsers that honor it jump straight to the line.
- Include a header block: repo name (from git remote or README), primary language(s), license (read from `LICENSE` if present), generated date.
- Include a footer note that Chrome and Edge block `file://`-to-`file://` link clicks by default; mention launching with `--allow-file-access-from-files --user-data-dir=/tmp/<profile>` to enable clickthrough. Firefox and Safari follow `file://` links without flags.

### Step 5 - validate every link

After writing, walk the generated HTML, extract every `href="file:///..."`, strip the `#Lxx` fragment, and confirm each target exists on disk. Use a quick Python or shell pipeline. Report the total link count and resolve rate (e.g. "156/156 links resolve, 100%"). Fix or remove any broken link before declaring done.

## Quality bar

- Every cited line must be a real symbol (struct / enum / fn / const) the reader would care about - not random whitespace.
- Prose should explain *how the primitive is implemented in this specific repo*, not how the abstract concept works in general.
- Pages should be readable in 5–10 minutes. Cap each section at ~250 words of prose plus the citation list.
- Render-tested: open the file in a browser and confirm the layout doesn't break (the validation step exists so the citations work; the HTML itself should be visually clean).

## Don'ts

- Don't pull in any external CSS / JS / fonts. The page must work offline with zero network access.
- Don't invent file paths. If a primitive doesn't exist in this repo, say so in that section's prose and skip the citation list for it.
- Don't put the full source code into the HTML - only citations + prose. The reader's editor opens the cited files.
- Don't generate placeholder lorem ipsum if the codebase is unfamiliar. Spend the time exploring.
