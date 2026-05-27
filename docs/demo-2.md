# Demo 2 — Twenty CRM, Live Feature Build (4-Prompt Loop)

Target repo: `./workshop/twenty`
Feature: Opportunity Confidence (default 20%) + Expected Value column with footer total

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

Wait for http://localhost:3001 to load.

### Claude session

```bash
cd ./workshop/twenty
claude
```

If superpowers isn't installed yet in this container:

```
/plugin marketplace add anthropics/claude-plugins-official
/plugin install superpowers@claude-plugins-official
```

Verify Playwright MCP:

```
/mcp list
```

---

## Prompt 1 — Project review

```
Please review and summarize the project. Include the number of files and lines of code in the source (not including node_modules), and the high level structure.
```

---

## Prompt 2 — Feature design, no code

```
I'd like to build a new feature: Opportunity Confidence
1. Every Opportunity in the database to have a confidence that defaults to 20%
2. In the frontend, in the Opportunities tab, show the opportunity confidence for each opportunity; allow the user to change the confidence to 0-100%; also show a column for "Expected Value" (confidence * value) for each opportunity, with a total expected value at the bottom
Do not start work yet — please let me know if you have any questions or thoughts about this.
```

---

## Prompt 3 — Plan, still no code

```
Now please write a detailed file called CONFIDENCE_PLAN.md in the project root directory that lists out all the steps and tasks involved together with tests and success criteria at each stage in turn. Do not start work.
```

---

## Prompt 4a — Execute

```
Plan looks good. Execute CONFIDENCE_PLAN.md. Use fresh subagent per task — zero context inheritance. You orchestrate, you don't implement directly.
```

## Prompt 4b — Self-review

```
Please write a file CODE_REVIEW.md in the project root that lists out the key changes made and give a self-appraisal of every major change. At the end, summarize overall feedback and issues, including anything that needs to be fixed now and any future improvements.
```

---

## Optional verification — Playwright MCP

```
Use Playwright MCP to verify the new Confidence feature end-to-end. Navigate to localhost:3001, log in if needed, go to Opportunities, pick the first row, change Confidence to 75, blur to save. Reload, verify Confidence is 75 and Expected Value reflects 75% × amount. Use the accessibility tree, not screenshots.
```

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
