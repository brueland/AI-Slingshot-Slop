---
id: 268c-checkpoint-hills
status: ready
tests: [tests/acceptance/test_268c_checkpoint_hills.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 36: rolling hills

Milestone 36 (tasks 261-267) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 35: complete (bouncier: more bounce, springs and balloons count a touch of the alien's body, UFO tractor beams pull the alien up)
```
REPLACE:
```gdscript
Milestone 35: complete (bouncier: more bounce, springs and balloons count a touch of the alien's body, UFO tractor beams pull the alien up)
Milestone 36: complete (rolling hills: gentle hills that grow with the rounds and the best distance, bounces off slopes, everything stands on the hills)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 36: complete`, and every earlier milestone line is still there.
- All tests pass.
