# Data Track — Week 1 Assignment

The HackYourFuture Data Track Week 1 assignment: **The Data Cleaning Pipeline**.

> Full instructions, learning context, and submission flow live in the
> curriculum chapter:
> [Week 1 Assignment on Notion](https://www.notion.so/hackyourfuture/Week-1-Assignment-The-Data-Cleaning-Pipeline-3cc37d4bf482470cbc6667bd1d1bb605).
> Read it first; this README is a quick reference.

## How to start

1. Click **Use this template** → **Create a new repository** under your own GitHub account.
2. Clone *your* copy locally.
3. `git switch -c week1-attempt`
4. Work through the three tasks below.
5. Push and open a PR against your repo's `main`. The auto-grader runs on every push and posts a score comment.

## Tasks at a glance

| Task | Folder | Points | What you build |
|---|---|---|---|
| **Task 1** — Cleaner Pipeline | `task-1/` | 60 | A modular Python pipeline that reads `data/messy_users.csv`, cleans each field via helpers in `src/utils.py`, validates, and writes JSON to `output/clean_users.json`. |
| **Task 2** — AI Debug Report | `task-2/` | 20 | Document one debugging session where you used an LLM to fix a bug. Fill in the four sections of `AI_DEBUG.md`. |
| **Task 3** — HYF Azure proof | `task-3/` | 20 | Accept the HYF Azure tenant invite, switch to that directory, screenshot proof at `task-3/azure_proof.png`. |

Total: 100 · Passing: 60.

## Repository layout

```text
.
├── task-1/
│   ├── data/
│   │   └── messy_users.csv      # the dataset (committed; do not edit)
│   ├── src/
│   │   ├── cleaner.py           # entry point — fill in TODOs
│   │   └── utils.py             # field-cleaning helpers — fill in TODOs
│   └── output/
│       └── clean_users.json     # your cleaner writes here
├── task-2/
│   └── AI_DEBUG.md              # fill in the four sections
├── task-3/
│   └── azure_proof.png          # add your screenshot here
├── .hyf/
│   └── test.sh                  # auto-grader (read it to see exactly what it checks)
└── .github/workflows/
    └── grade-assignment.yml     # runs .hyf/test.sh on every PR
```

## Run the grader locally

Before opening a PR, run the same checks the auto-grader runs:

```bash
bash .hyf/test.sh
cat .hyf/score.json
```

This prints a per-task breakdown and writes `score.json`. Iterate until
`pass: true` (or until you've given it your best attempt), then push.

## Submission

Open a PR against your fork's `main`. Share the PR URL with your teacher.
