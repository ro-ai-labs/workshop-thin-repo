# Demo 3 — pr-review-toolkit on Spring Boot PR

**Target repo:** `~/workshop/spring-boot-pr-demo`
**Expected duration:** ~8 min

---

## The three deliberate issues in the PR

The `demo/risky-changes` branch contains three ITSS-banking-relevant defects
planted intentionally:

1. **SQL injection** — `CustomerLookupDao.findByIbanRaw()` concatenates the IBAN
   parameter directly into JPQL instead of using a `:iban` named binding.
2. **Swallowed exception** — `TransferService.executeTransfer()` catches
   `DataAccessException` with an empty catch body and returns `false`, silently
   hiding the failure.
3. **Missing test** — the new `executeTransfer(fromIban, toIban, amount)` method
   has zero test coverage.

---

## Setup

```bash
cd ~/workshop/spring-boot-pr-demo
git checkout demo/risky-changes
git diff main..HEAD --stat
# Expect: 2 files modified, ~70 insertions
```

---

## Step 1 — Show the PR diff (~1 min)

```bash
git diff main..HEAD --stat
git diff main..HEAD
```

Don't dwell. The agents will find the issues. The point is to let the audience
see a plausible PR before the agents run.

---

## Step 2 — Silent Failure Hunter (~3 min)

Start a Claude Code session:

```bash
claude
```

**Inside the Claude Code session:**

```
Use the silent-failure-hunter agent on the current PR changes.
```

**Expected output (30–60 sec):** Finds the swallowed `DataAccessException` in
`TransferService.executeTransfer()`. Reports the catch block, file:line, and
explains the failure mode.

**Narration:**
> "Your 'swallowed exception' problem? There is literally an agent called
> 'Silent Failure Hunter' for that. It reads every catch block, every error path,
> every place where a failure could be silently ignored."

After output:
> "Found it. Swallowed exception. In manual review, it's the kind of thing that
> slips through on a Friday afternoon when the reviewer is tired. The agent never
> gets tired."

**Recovery if Silent Failure Hunter finds nothing:**

```
Look at the catch blocks in the PR. Are any exceptions caught without being logged or rethrown? Specifically look at TransferService.java.
```

**Recovery if Silent Failure Hunter finds too many issues (>5):** Say "Let me
focus on the critical ones." Pick top 2 by severity. The insight is WHAT it
finds, not HOW MANY.

---

## Step 3 — PR Test Analyzer (~3 min)

```
Run the PR Test Analyzer on the current PR changes. Show coverage gap priorities.
```

**Expected output (30–60 sec):** Coverage gaps scored 1–10. The new
`executeTransfer()` method flagged as high priority (8–10). Specific test
recommendations provided.

**Narration:**
> "PR Test Analyzer scores coverage gaps 1–10. A score of 8–10 means 'this will
> break in production if you do not test it.' A 3–4 is 'nice to have.' The
> prioritisation is the value — not just 'more tests' but 'TEST THIS first.'"

**Recovery if output is unclear:** Narrate the key finding yourself: "The
analyzer flagged the new `executeTransfer` method as the highest-priority gap.
That's the right call — new code without tests is the biggest risk in any PR."

---

## Step 4 — Review insight (~1 min)

> "6 agents in 2 minutes vs. 6 reviewers in 2 days. And they don't skip Friday
> evening."

> "The full toolkit has 6 agents: Comment Analyzer, PR Test Analyzer, Silent
> Failure Hunter, Type Design Analyzer, Code Reviewer, Code Simplifier. We ran 2.
> In real flow, you run them all."

**Slash-command alternative — if running ahead of schedule, or if asked:**

```
/pr-review-toolkit:review-pr errors tests
```

Or let the command pick the relevant agents automatically:

```
/pr-review-toolkit:review-pr all
```

Note: on this small PR (2 files, no new types, no comment edits), `all` fires
~3 of 6 agents — the others have nothing material to review. Do not promise
"all 6 run."

---

## What to watch for (per agent)

| Agent | What it flags on this PR |
|---|---|
| `silent-failure-hunter` | Swallowed `DataAccessException` in `TransferService.executeTransfer()` |
| `pr-test-analyzer` | Zero coverage on new `executeTransfer()` method; score 8–10 |
| `code-reviewer` | IBAN string concatenation in JPQL (SQL injection path) |

---

## Cheatsheet reference

The **Kill Signal Decision Card** in the handout (`~/workshop/docs/`) covers the
governance decision tree for blocking a PR vs. flagging vs. passing — the
framework that turns these agent findings into an actionable code-review policy.
