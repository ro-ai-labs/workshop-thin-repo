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
Use superpowers to build a new feature: Opportunity Confidence. Let's start by brainstorming about it and the defining the specifications. Every Opportunity in the database should have a confidence field that defaults to 20%, and in the frontend Opportunities tab show that confidence per row, let me change it to any value 0-100%, and add an Expected Value column equal to confidence × amount per row with a footer total across all visible rows. Before you touch any code, run a baseline Playwright e2e against the running Twenty dev server - log in, go to Opportunities, and assert that today there's no Confidence field on a row and no Expected Value column - that locks in the starting state. After the feature is built, run Playwright again against the same dev server: set Confidence to 75 on the first opportunity, blur to save, reload, and assert that Confidence persists as 75, that Expected Value equals 75% × amount, and that the footer total updates across all visible rows. Use the accessibility tree for assertions, not pixel screenshots, and make sure `.playwright-mcp/` is in `.gitignore` so traces and debug screenshots don't end up in commits. Self-review at the end with an explicit before-vs-after comparison drawn from the two Playwright runs.
```

Superpowers self-paces through brainstorm, plan, execute, self-review. Natural
pause points in the live session: after the brainstorm settles, after the plan
is written, after execution finishes. Confirm and let it carry on.

Push back if the agent invents a spec detail or skips either Playwright run.
Both before AND after e2e must happen.

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
