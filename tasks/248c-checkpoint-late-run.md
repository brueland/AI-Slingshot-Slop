---
id: 248c-checkpoint-late-run
status: ready
tests: [tests/acceptance/test_248c_checkpoint_late_run.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 32: late-run HUD and grab

Milestone 32 (tasks 245-247) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 31: complete (boss fights: every 10th roguelike round the Grumblor stands on the field with targets on and around its body, 4 shots to knock out its HP, results for every hit, +1 life for beating it)
```
REPLACE:
```gdscript
Milestone 31: complete (boss fights: every 10th roguelike round the Grumblor stands on the field with targets on and around its body, 4 shots to knock out its HP, results for every hit, +1 life for beating it)
Milestone 32: complete (late-run HUD and grab: perks as boxes with counts, goal lines wrap so the right panel stays on screen, grab the alien anywhere on it)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 32: complete`, and every earlier milestone line is still there.
- All tests pass.
