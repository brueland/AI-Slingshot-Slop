---
id: 251c-checkpoint-endless
status: ready
tests: [tests/acceptance/test_251c_checkpoint_endless.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 33: endless meadow

Milestone 33 (tasks 249-250) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 32: complete (late-run HUD and grab: perks as boxes with counts, goal lines wrap so the right panel stays on screen, grab the alien anywhere on it)
```
REPLACE:
```gdscript
Milestone 32: complete (late-run HUD and grab: perks as boxes with counts, goal lines wrap so the right panel stays on screen, grab the alien anywhere on it)
Milestone 33: complete (endless meadow: the ground and distance markers never end, seamless far hills, scenery to 8000 m)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 33: complete`, and every earlier milestone line is still there.
- All tests pass.
