---
id: 256c-checkpoint-star-power
status: ready
tests: [tests/acceptance/test_256c_checkpoint_star_power.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 34: star power

Milestone 34 (tasks 252-255) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 33: complete (endless meadow: the ground and distance markers never end, seamless far hills, scenery to 8000 m)
```
REPLACE:
```gdscript
Milestone 33: complete (endless meadow: the ground and distance markers never end, seamless far hills, scenery to 8000 m)
Milestone 34: complete (star power: every roguelike star counts for the run and gives a small random boost, shown on the HUD and after each shot)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 34: complete`, and every earlier milestone line is still there.
- All tests pass.
