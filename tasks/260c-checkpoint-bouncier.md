---
id: 260c-checkpoint-bouncier
status: ready
tests: [tests/acceptance/test_260c_checkpoint_bouncier.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 35: bouncier

Milestone 35 (tasks 257-259) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 34: complete (star power: every roguelike star counts for the run and gives a small random boost, shown on the HUD and after each shot)
```
REPLACE:
```gdscript
Milestone 34: complete (star power: every roguelike star counts for the run and gives a small random boost, shown on the HUD and after each shot)
Milestone 35: complete (bouncier: more bounce, springs and balloons count a touch of the alien's body, UFO tractor beams pull the alien up)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 35: complete`, and every earlier milestone line is still there.
- All tests pass.
