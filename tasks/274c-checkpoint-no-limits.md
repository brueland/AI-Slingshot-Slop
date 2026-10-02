---
id: 274c-checkpoint-no-limits
status: ready
tests: [tests/acceptance/test_274c_checkpoint_no_limits.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 38: no limits

Milestone 38 (tasks 272-273) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 37: complete (steady ghost: Steady Hand shows the last shot's path while aiming, and the aim line is only drawn while aiming)
```
REPLACE:
```gdscript
Milestone 37: complete (steady ghost: Steady Hand shows the last shot's path while aiming, and the aim line is only drawn while aiming)
Milestone 38: complete (no limits: classic upgrades go to level 25, endless milestones every 1000 m)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 38: complete`, and every earlier milestone line is still there.
- All tests pass.
