# Demo 1 — Live Architecture Review: Codex (Rust) + opencode (TypeScript)

**Target repos:** `~/workshop/codex` (Pane A) and `~/workshop/opencode` (Pane B)
**Expected duration:** 15–18 min
**Third pane (Pane C):** `~/workshop/` — used for live plugin install in P4

---

## Setup

Two terminal panes, each with a running `claude` session:

```bash
# Pane A
cd ~/workshop/codex
claude

# Pane B
cd ~/workshop/opencode
claude
```

Both Claude Code instances are isolated. Same prompt goes into both, in
succession, and both run concurrently.

---

## P1 — Side-by-side architecture review (~3–4 min)

**Type this prompt in BOTH Pane A and Pane B (in succession; let them run in parallel):**

```
Explain the architecture of this codebase. Map (a) the agent loop, (b) tool definitions and registration, (c) permission/approval logic, (d) sandbox or isolation mechanism, (e) plugin/extension model. Cite file:line for each finding.
```

**What to expect:**

- **Pane A (Codex, Rust):** Rust modules under `codex-rs/` — agent loop crate,
  tool trait definitions, approval/permission logic, sandbox implementation,
  plugin/extension surface. Real source code with file:line citations. Subagent
  dispatch surfaces organically as Codex's headline feature.
- **Pane B (opencode, TypeScript):** TypeScript modules under `packages/` —
  agent runtime, tool interfaces, permission gates (the "plan agent denies file
  edits by default" gate), sandbox abstraction, extension model. Subagent-
  equivalent dispatch surfaces under a less prominent name.

**Narration after both panes return:**
> "Same prompt, two isolated Claude Code instances, live architecture review of
> two open-source coding agents in parallel. Rust on the left, TypeScript on the
> right. When both return — the same set of primitives in both — context window,
> tools, skills, plugins, MCP, memory, subagents. A language difference, NOT an
> architecture difference. Architecture is invariant."

**Recovery — output too shallow:**
```
Look at the plugins/ directory and explain the plugin manifest structure.
```

**Recovery — permission system not found:**
```
Search for files related to permission checking, tool approval, or settings schema. Then explain how the Allow/Ask/Deny model is configured.
```

---

## P2 — Architecture HTML (~1–2 min on stage; live generation takes 8–10 min)

**Prompt in Pane A (Codex):**

```
Generate an interactive HTML architecture page at ./demo-examples/codex-architecture.html. Visualize Codex's modules (agent loop, tools, permissions, sandbox, plugins) with clickable file:// links to the actual source files in this repo. Use simple HTML + CSS, no external dependencies. Self-contained, openable in a browser.
```

**Prompt in Pane B (opencode):**

```
Generate an interactive HTML architecture page at ./demo-examples/opencode-architecture.html. Visualize opencode's modules (agent loop, tools, permissions, sandbox, plugins) with clickable file:// links to the actual source files in this repo. Use simple HTML + CSS, no external dependencies. Self-contained, openable in a browser.
```

**Do NOT wait for live completion.** Each pane takes ~8–10 min. After ~30 sec,
acknowledge and open the pre-rehearsed fallback HTMLs. The audience sees the
prompt running, then the artifact — not the wait.

**Open fallbacks (recommended path):**

```bash
chrome-workshop ~/workshop/demo-examples/codex-architecture-fallback.html
chrome-workshop ~/workshop/demo-examples/opencode-architecture-fallback.html
```

`chrome-workshop` is a PATH launcher that wraps
`google-chrome --allow-file-access-from-files --user-data-dir=/tmp/chrome-workshop`
so `file://` → `file://` navigation works inside the HTMLs. Zoom 110–125% for
projector.

**Live open (only if both panes finish before the demo block ends):**

```bash
chrome-workshop ~/workshop/codex/demo-examples/codex-architecture.html
chrome-workshop ~/workshop/opencode/demo-examples/opencode-architecture.html
```

**Narration:**
> "Two navigable maps, generated live. Click on any module — it takes you into
> the source. This is what you take home on your legacy codebases."

**Recovery if generation fails:** Use the pre-rehearsed fallbacks above. Say:
"I generated these earlier with the exact same prompt — let me show you what
comes out, side-by-side." Audience won't notice the swap.

---

## P2.5 — Understand-Anything dashboard reveal (~1.5 min on stage; pre-generated the night before)

This step is **pre-baked**. The dashboard was generated the night before via
`/understand` on `~/workshop/codex` (takes 3–5 min; not done live).

**Slash command — run in the existing Pane A Claude Code session (NOT a bash command):**

```
/understand-dashboard
```

This opens the pre-generated dashboard in the browser via `chrome-workshop`.
Shows:
- **Structural view:** file/function/class graph colour-coded by layer
- **Domain view:** business domains with extracted rules and entities

**Bridge from P2 (~10s, before switching):**
> "That was Plan A — simple prompt, interactive HTML, 8–10 min of generation in
> any Claude Code session. Now Plan B: a specialised plugin that turned the same
> code into a more polished dashboard. Open source MIT, installed pre-workshop,
> dashboard generated last night."

**Stage choreography (~1.5 min):** Structural view (~15s) → Domain view (~30s,
the management moment) → click one node for detail panel (~30s) → close with
"two horizons, both valid, pick by constraint" framing (~15s).

**Codex only on stage.** The opencode dashboard is also pre-generated and
linked from the handout, but not shown live.

**Fallback if dashboard fails to open:** Skip P2.5 entirely. The P2 fallback
HTMLs are still on screen. Narrate: "Plan B had a pre-generated dashboard but
it's not opening now. Link in the handout." Do NOT spend >30 sec debugging —
P2.5 is not load-bearing.

---

## P3 — Architecture review lesson (~3 min, no new Claude prompt)

Side-by-side narration walking through the primitives visible in each diagram.
Mihai stands front, points at each browser as he names each primitive.
**No new Claude Code prompt.** This is the teaching beat that earns the
previous two steps and sets up governance.

Primitives called out one by one with file paths from the diagrams:
- context window
- tools
- skills
- plugins
- MCP
- memory (CLAUDE.md / AGENTS.md — the always-loaded instruction file at each repo root)
- subagents (Codex: headline feature in `codex-rs/`; opencode: same dispatch
  pattern under a less prominent name in `packages/`)

**Decision-model line lands here:**
> "Pick the tool by constraint — language, license, ecosystem fit, audit needs —
> not by hype. Architecture is invariant."

The sandbox-tradeoff finding bridges into the four-layer governance framework
that follows. Mention the **MCP Supply Chain Review cheatsheet** in the
handout for the full MCP vendor list (Atlassian Rovo, GitHub MCP, Postgres MCP
alternatives).

---

## P4 — Install Hookify in a third Claude Code session (~2–3 min)

**Open Pane C** (pre-cd'd to `~/workshop/`), start a fresh Claude Code session:

```bash
claude
```

**Inside that Claude Code session (NOT bash):**

```
/plugin install hookify@claude-plugins-official
```

Expect: 5–15 sec install, confirmation message.

**Narration:**
> "In parallel with the two exploration sessions, I'm opening a third Claude
> Code session and installing a plugin live. Three instances in flight
> simultaneously. The same extension pattern we saw in Codex and opencode.
> Starter pack for you: five plugins — hookify, security-guidance, superpowers,
> pr-review-toolkit from the official marketplace, plus understand-anything from
> the author's marketplace (one extra `/plugin marketplace add`). Install on
> each machine day 1."

---

## P5 — MCP name-drop (~1 min, no Claude prompt)

Brief verbal callout only. MCP is the integration standard that makes the agent
portable across vendors. Both Codex and opencode support MCP. Atlassian Rovo
MCP for Jira/Confluence, GitHub MCP, maintained Postgres MCP alternatives.
Full vendor list in the **MCP Supply Chain Review cheatsheet**.
