# Overnight task queue

One task per file: `NNN-short-name.md`. The overnight orchestrator (selfhosted_llm) runs tasks whose
`status` is `ready`, each on its own `ai/<task>--<date>` branch. It never pushes or merges.

```
---
id: 003-dash-ability
status: draft            # draft = not run. Change to ready after you've reviewed the task AND its test.
tests: [tests/acceptance/test_003_dash_ability.gd]   # read-only acceptance tests: done = these pass
files: [scripts/player.gd]                           # files the agent should start from (optional)
---

# Add a dash ability
What to build, where, and any constraints.
```

- Plan tasks from a goal: `.\scripts\overnight.ps1 plan -Project <this repo> -Goal "..."`
- Approve drafts: `.\scripts\overnight.ps1 approve -Project <this repo> -All`
- Stop tonight's run: create a file named `STOP` in this folder.
- Edit a task after a needs-human result and it runs again the next night.
