# Demo 2 - Twenty CRM, Live Feature Build (Superpowers Loop)

Target repo: `./workshop/twenty`
Feature: Opportunity Confidence (default 20%) + Expected Value column with footer total

This demo builds directly on Demo 1. The `architecture-html` skill scaffolded
in Demo 1 P6 is reused here to orient on Twenty, and `superpowers` (installed
in Demo 1 pre-flight) drives the full brainstorm -> plan -> TDD execute ->
self-review loop. No standalone "design", "plan", or "review" prompt -
superpowers covers all three.

---

## Pre-flight

### Infrastructure

```bash
docker run -d --name twenty-postgres \
  -p 5432:5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=default \
  postgres:16

docker run -d --name twenty-redis -p 6379:6379 redis
```

### Platform startup

```bash
cd ./workshop/twenty
nvm install
nvm use
yarn
npx nx database:reset twenty-server
npx nx start
```

Wait for the dev server to print its local URL and load it in the browser. (Twenty's `nx start` picks a free port - typically 3000 or 3001 - so trust whatever it prints, don't assume.)

### Claude session

```bash
cd ./workshop/twenty
claude
```

Verify the plugins from Demo 1 carried over:

```
/plugin list
```

Expected: `superpowers` (installed in Demo 1 pre-flight) and `architecture-html`
(scaffolded + installed in Demo 1 P6). If `architecture-html` is missing,
install it from the local marketplace:

```
/plugin marketplace add ./workshop/itss-plugins
/plugin install architecture-html@itss-plugins
```

Verify Playwright MCP:

```
/mcp list
```

---

## Prompt 1 - Orient with the architecture-html skill (carry-over from Demo 1)

```
Use the architecture-html skill to produce an architecture page for this repo.
```

Output: `./docs/architecture-map.html` - read-only orientation of Twenty's
NestJS server, Vite/React front, GraphQL bridge, Postgres + Redis infra,
with clickable `file://` links to source. This is the ground truth the next
prompt's design conversation hangs off - the agent has structured knowledge
of where Opportunity lives before being asked to extend it.

---

## Prompt 2 - Build the feature with superpowers (with before/after Playwright e2e)

```
Use superpowers and let's brainstorm against the spec below - confirm every
detail with me before moving to a plan or any code.

NEW FEATURE - Opportunity Confidence + Expected Value

- New field `confidence` on Opportunity: integer 0-100
  (percentage, NOT decimal). Default 20. Backfill existing rows
  with 20.
- Inline row editor in the Opportunities list - spinbutton,
  min 0, max 100, step 1. Blur to save.
- New `Expected Value` column on each row: confidence/100 ×
  amount, currency-formatted the same way `amount` is.
- Footer total: sum of Expected Value across all visible rows
  on the current page. Update reactively when any row's
  confidence changes.
- Expose both `confidence` (raw integer) and the computed
  expected value on the Opportunity GraphQL DTO so the public
  API exposes both.

IMPLEMENTATION GOTCHA - metadata cache

Twenty keys its metadata cache by `workspace.metadataVersion`.
Generate migrations through `database:migrate:generate` - that
pipeline bumps `metadataVersion` for you. Hand-rolled SQL or
direct edits to metadata tables do NOT bump it, and the new
field won't appear in GraphQL introspection or the UI. After
the migration runs, verify the field shows up in GraphQL
introspection before trusting it from the frontend.

VALIDATION - Playwright e2e, before AND after (both mandatory)

Before any code change, drive Playwright MCP against the
running Twenty dev server. Log in, navigate to Opportunities,
and assert via the accessibility tree that there is NO
Confidence spinbutton on any row and NO Expected Value column
header. This is the baseline.

After the feature is built, drive Playwright MCP again. On
the first Opportunity row: set Confidence to 75, blur to save,
reload the page, and assert via the accessibility tree that:
- Confidence persists as 75 after reload
- Expected Value equals (75/100) × amount, currency-formatted
- Footer total equals Σ(confidence/100 × amount) across the
  visible rows and updates when another row's confidence changes

Use the accessibility tree (`getByRole`, `getByLabel`), never
pixel screenshots. Add `.playwright-mcp/` to `.gitignore` so MCP
traces don't end up in commits.
```

Superpowers self-paces brainstorm → plan → execute → self-review.
Confirm at each natural pause and let it carry on.

### Pushback triggers - facilitator's reset list

Most discipline (TDD, plan completeness, brainstorm-before-code) is
enforced by superpowers itself. These three aren't, so watch for them:

| Trigger | Reset |
|---|---|
| Agent invents a spec detail (audit log, separate settings page, etc.) | Reject; the spec in the prompt is the contract |
| Agent skips the baseline or the post-impl Playwright run | Reject the completion claim |
| Field added but doesn't show in UI / GraphQL introspection | Stale metadata cache - check whether the migration went through `database:migrate:generate` (which bumps `workspace.metadataVersion`) before debugging anything else |

---

## Stopping the platform

In the terminal running `npx nx start`: `Ctrl+C`.

```bash
docker rm -f twenty-postgres twenty-redis
```

---

## Anti-slop checklist

When working with less capable models, tell the agent to avoid these and code-review against them:

1. Verbose, defensive, over-commented code
2. Unnecessary README files
3. Testing artifacts left around (screenshots, temp files)
4. Use of emojis
5. Brittle unit tests that over-mock

## PR description

Write the PR description yourself, not the agent.
