---
id: 271c-checkpoint-steady
status: ready
tests: [tests/acceptance/test_271c_checkpoint_steady.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 37: steady ghost

Milestone 37 (tasks 269-270) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 36: complete (rolling hills: gentle hills that grow with the rounds and the best distance, bounces off slopes, everything stands on the hills)
```
REPLACE:
```gdscript
Milestone 36: complete (rolling hills: gentle hills that grow with the rounds and the best distance, bounces off slopes, everything stands on the hills)
Milestone 37: complete (steady ghost: Steady Hand shows the last shot's path while aiming, and the aim line is only drawn while aiming)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 37: complete`, and every earlier milestone line is still there.
- All tests pass.
