# Demo 2 — Superpowers Install + 6 Phases LIVE on Twenty CRM

**Target repo:** `~/workshop/twenty`
**Feature target:** Add `Priority` enum field (low / medium / high) to Twenty's `Opportunity` record
**Expected duration:** ~22 min live terminal (Block 2A total: 26 min including 3-min slide opening)

---

## Pre-flight

The Twenty dev server must be running before the demo block starts.

```bash
cd ~/workshop/twenty
docker compose up -d          # Postgres + Redis
yarn start                    # dev server on localhost:3000
```

Wait until the browser at `http://localhost:3000` shows the Twenty UI.
Verify Playwright MCP is available inside a Claude Code session:

```
/mcp list
```

`playwright` must appear in the list.

---

## Step 1 — Install Superpowers Live (~1 min)

Open a Claude Code session in `~/workshop/twenty`:

```bash
cd ~/workshop/twenty
claude
```

**Inside the Claude Code session (NOT bash):**

```
/plugin install superpowers@claude-plugins-official
```

Expect: 5–15 sec install. Plugin manifest appears. Core workflow skills load:
brainstorming, writing-plans, subagent-driven-development, requesting-code-review,
receiving-code-review, verification-before-completion, finishing-a-development-branch,
systematic-debugging, test-driven-development, using-superpowers.

**Narration:**
> "Watch this. [run the install]. Done. The methodology is now installed. Skills,
> rules, workflows. Versionable, diffable through git. Discipline committed."

**"Laptops Open" pause (~30 sec):**
> "If you already have Claude Code installed and logged in, open a session with
> `claude` and run `/plugin install superpowers@claude-plugins-official` — in
> parallel with me. If you don't have Claude Code yet, the handout has the
> complete steps — setup takes ~10 minutes and you do it Monday morning.
> Now: 30 seconds."

Move on whether they finish or not.

---

## Step 2 — Live demo framing + Manager Hook #1 (~1 min)

> "Twenty: Y Combinator startup, open-source CRM, large TypeScript monorepo. Has
> CLAUDE.md committed — the Twenty team wrote it for AGENTS. The feature: we add
> a Priority field on Opportunity. Small, end-to-end, visible. Playwright at the end."

**Manager hook #1:**
> "For the managers: we're not copying the speed or the stack into banking Spring
> Boot. We copy the discipline: research gate, plan.md, bounded execution, review,
> verification, and human acceptance."

---

## Phase 1 — RESEARCH (~3 min)

```
/brainstorm I want to add a "Priority" field (enum: low/medium/high) to Opportunity records in Twenty. Don't write code yet. Read the codebase, find the existing Opportunity entity, identify the migration pattern, and ask clarifying questions about: data type, default value, required vs optional, UI placement, API contract, migration strategy.
```

**Expected output:** Agent reads `CLAUDE.md`, scans Opportunity-related code
(entity, migrations, GraphQL, form), then surfaces 5–7 clarifying questions:
- Should Priority be a Postgres enum or a string column with app-level validation?
- Default value when creating a new Opportunity?
- Should existing Opportunities backfill (set medium) or remain NULL?
- Where in the form UI — above Stage, below Stage, separate section?
- Should it appear in the list/table view or only in detail/edit form?
- Should the kanban pipeline view filter by Priority?
- GraphQL type: do we want it on the public API or workspace-internal only?

**Mihai's rehearsed answers (memorize):**
- Postgres enum (`priority_enum`), not string
- Default `medium` for new Opportunities
- Existing rows: backfill `medium`
- UI: above Stage in the form
- List view: yes, show as colored chip (low=gray, medium=blue, high=red)
- Kanban: not in v1, future iteration
- GraphQL: public API, expose in Opportunity DTO

**Push-back trigger:** If agent jumps to write code without asking questions,
interrupt: "Stop. Read the brainstorming skill — HARD-GATE engages. Ask me
questions first."

**Manager hook #2:**
> "HARD-GATE = the agent cannot write code until you approve the design. Your
> discipline: through your CLAUDE.md."

**Recovery if `/brainstorm` stalls or goes off-topic:** Play
`fallback-twenty-priority-research.mp4` and narrate.

---

## Phase 2 — PLAN (~3 min)

```
Good. Based on those answers, now write a written plan in plan.md with file-level decomposition. Each task should be 2-5 minutes. Include success criteria and test criteria. Do not start work yet.
```

**Expected `plan.md` contents:**
- 6 file-level tasks: enum definition, entity update, migration, GraphQL query,
  form component, list chip
- Each task 2–5 min with explicit file paths
- Success criteria + test criteria sections

**Push-back triggers (catch within 10 sec):**
- No success criteria → "Ask for success criteria."
- No file paths, just task names → "File-level decomposition FIRST. Which files?"
- Tasks longer than 5 min → "Break task X down further."
- Missing migration plan → "How do we backfill existing rows?"

**Manager hook #3:**
> "Plan committed in git — when auditor asks 'how was this change made', the
> answer is plan-hash + commit-hash. Governance committed in repo."

---

## Phase 3 — EXECUTE (~5 min)

```
Plan looks good. Execute the plan. Use fresh subagent per task - zero context inheritance. You orchestrate, you don't implement directly.
```

**Expected behavior:** Subagent dispatches visible in Claude Code UI. Each task
1–3 min. 6 files modified. Tests are NOT run in this phase (that's Phase 5).

**Manager hook #4 (mid-execute):**
> "Subagent isolation = bounded context. Task fails → doesn't contaminate others.
> Each commit has clear scope."

**Recovery if EXECUTE hangs >60 sec:** Play `fallback-twenty-priority-execute.mp4`.
Show the completed diff and narrate. Then `claude --continue` on the
`demo-after-phase-3` branch to resume cleanly.

---

## Phase 4 — REVIEW (~2 min)

```
Now write code_review.md with a self-appraisal: what worked, what compromises did you make, what would you change if you had more time, what issues did you notice but not fix.
```

**Expected `code_review.md` — at minimum two self-identified compromises:**
- No enum validation at the API layer (GraphQL resolver accepts enum but doesn't
  guard against invalid values; relying on Postgres to reject)
- Hardcoded English labels in OpportunityForm instead of i18n keys (`t('priority.low')`)

**Talking point:**
> "See — the agent caught two compromises on its own. Two iterations ago we would
> have looked for them together; now they're on screen. Self-review does not
> replace human review — it informs it."

**Manager hook #5:**
> "Scales review with team — every PR comes with the agent's own self-appraisal
> as a starting point for the reviewer."

---

## Phase 5 — VERIFY with Playwright (~5 min) — WOW MOMENT

```
Now use Playwright MCP to verify the new Priority field works end-to-end. Navigate to localhost:3000, log in if needed, go to Opportunities, create a new Opportunity called "Test priority", set Priority to High, save it. Then reload the page, open the same Opportunity, and verify Priority displays as High. Use the accessibility tree, not screenshots.
```

**Expected behavior:**
- Browser opens via `chrome-workshop` launcher
- Agent drives via accessibility-tree selectors:
  - `getByRole('link', { name: /opportunities/i })`
  - `getByRole('button', { name: /create|add/i })`
  - `getByLabel(/priority/i)`
  - `getByRole('option', { name: /high/i })`
  - `getByRole('button', { name: /save/i })`
  - `getByLabel(/priority/i)` after reload → value matches `/high/i`
- Final assertion: Priority field shows "High" after reload. Test passes.

**Narrate each step on stage:**
- "Browser open on Twenty."
- "Click Opportunities. Click Create."
- "Form loads — see Priority above Stage."
- "Select High. Save."
- "Reload. Priority = High. PASSED."

> "Playwright MCP uses the accessibility tree, NOT screenshots. Stable across CSS
> refactors."

**Manager hook #6 — Diana Item 3 landing — DO NOT SKIP (even on recorded recovery):**
> "For those on frontend: what you just saw is the answer to 'how do we do TDD
> on UI'. Accessibility tree, NOT pixels. Stable under CSS refactor. On your
> codebase: a custom skill on `*.test.tsx`, plus a hookify rule that blocks
> commits on components without a sibling test. Details at T22 in the handout."

**Recovery if Playwright fails:** Play `fallback-twenty-priority-verify.mp4`.
Alternatively, open the test file in editor and narrate each assertion. Do NOT
debug live >30 sec. Manager hook #6 must still be delivered even on recorded
recovery.

**Full Playwright test outline** (for reference / narration):

```typescript
test('Priority field on Opportunity - full create + reload + verify', async ({ page }) => {
  await page.goto('http://localhost:3000');

  // Navigate to Opportunities
  await page.getByRole('link', { name: /opportunities/i }).click();
  await expect(page.getByRole('heading', { name: /opportunities/i })).toBeVisible();

  // Create new Opportunity
  await page.getByRole('button', { name: /create|add/i }).click();
  await page.getByLabel(/name/i).fill('Test priority field');

  // Set Priority = High (field should be above Stage in form)
  await page.getByLabel(/priority/i).click();
  await page.getByRole('option', { name: /high/i }).click();

  // Save
  await page.getByRole('button', { name: /save/i }).click();
  await expect(page.getByText(/saved|created/i)).toBeVisible();

  // Reload (verify persistence)
  await page.reload();

  // Open the Opportunity we just created
  await page.getByText('Test priority field').click();

  // Verify Priority displays as High
  await expect(page.getByLabel(/priority/i)).toHaveValue(/high/i);
  // OR if it's a chip:
  await expect(page.getByText(/high/i)).toBeVisible();
});
```

---

## Phase 6 — SHIP (~1 min)

```
Phase 6: show me the worktree state and what a PR would contain. Don't push - this is demo only. Confirm no test artifacts leaked into the working tree.
```

**Expected:** `git status` shows 6 modified files + 1 new migration file. No
`.png` screenshots from Playwright (accessibility-tree mode doesn't generate
them). No `.lock` runtime files. No leftover test data.

> "Worktree clean. The demo stays local — we are not Twenty maintainers. PR via
> `gh` CLI; Jira MCP + Slack MCP wired up = link PR to ticket + Slack notification
> end-to-end."

---

## Demo wrap + team-wide fold-in (~1 min)

> "You saw six phases. 20 minutes. A large TypeScript monorepo. Brainstorm →
> plan.md → diff → code_review.md → Playwright pass → worktree clean. And a note
> on team scale: the PM — 'intelligent orchestrator' — structures requirements
> from Jira/Confluence. The developer runs Superpowers. QA generates tests with
> pr-review-toolkit. The PM updates status from committed artifacts. The whole
> team, not a single role."

---

## Recovery reference

| Failure | Recovery |
|---|---|
| Install errors | `fallback-twenty-priority-install.mp4` |
| `/brainstorm` stalls or off-topic | `fallback-twenty-priority-research.mp4` |
| EXECUTE hangs >60 sec | `fallback-twenty-priority-execute.mp4`; then `claude --continue` on `demo-after-phase-3` |
| Playwright fails | `fallback-twenty-priority-verify.mp4`; narrate assertions from test file |
| Any phase | 30-second rule: never debug live >30 sec; drop to video recovery immediately |

Ask Mihai to confirm which `demo-after-phase-N` branches exist before the
workshop (they may not all be cut yet).
