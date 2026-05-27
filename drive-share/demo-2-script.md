# Demo 2 — Twenty CRM, Live Feature Build

## Starting the infrastructure

```bash
docker run -d --name twenty-postgres \
  -p 5432:5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=default \
  postgres:16

docker run -d --name twenty-redis -p 6379:6379 redis
```

## Starting the platform

```bash
cd ~/workshop/twenty
nvm install
nvm use
yarn
npx nx database:reset twenty-server
npx nx start
```

## The 4 prompts

1. **Project review.**

   > Please review and summarize the project. Include the number of files
   > and lines of code in the source (not including node_modules), and the
   > high level structure.

2. **Feature request — no implementation yet.**

   > I'd like to build a new feature: Opportunity Confidence
   > 1. Every Opportunity in the database to have a confidence that defaults to 20%
   > 2. In the frontend, in the Opportunities tab, show the opportunity confidence
   >    for each opportunity; allow the user to change the confidence to 0–100%;
   >    also show a column for "Expected Value" (confidence × value) for each
   >    opportunity, with a total expected value at the bottom
   > Do not start work yet — please let me know if you have any questions or
   > thoughts about this.

3. **Plan, still no code.**

   > Now please write a detailed file called CONFIDENCE_PLAN.md in the project
   > root directory that lists out all the steps and tasks involved together
   > with tests and success criteria at each stage in turn. Do not start work.

4. **Self-appraised code review after implementation.**

   > Please write a file CODE_REVIEW.md in the project root that lists out the
   > key changes made and give a self-appraisal of every major change. At the
   > end, summarize overall feedback and issues, including anything that needs
   > to be fixed now and any future improvements.

## Stopping the platform

Ctrl+C in the terminal running the platform, then:

```bash
docker rm -f twenty-postgres twenty-redis
```

## Avoiding LLM slop

When you work with less capable models than Claude Opus 4.x, watch for these
five tells and instruct your coding agent to avoid them:

1. Overly verbose, defensive, and over-commented code
2. Unnecessary README files
3. Testing artifacts left around (screenshots, temp files) after completion
4. Use of emojis
5. Brittle unit tests that over-mock and don't actually test behavior

When code-reviewing (LLM or human), check explicitly against all five.

## Writing the PR

When you open the PR, **write the description yourself.** A verbose,
emoji-laden, LLM-generated PR description sends the wrong signal to your
reviewer. A short PR description in your own words shows you're accountable
for the code.
