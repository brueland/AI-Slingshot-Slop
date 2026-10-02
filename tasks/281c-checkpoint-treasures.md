---
id: 281c-checkpoint-treasures
status: ready
tests: [tests/acceptance/test_281c_checkpoint_treasures.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 39: treasures

Milestone 39 (tasks 275-280) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 38: complete (no limits: classic upgrades go to level 25, endless milestones every 1000 m)
```
REPLACE:
```gdscript
Milestone 38: complete (no limits: classic upgrades go to level 25, endless milestones every 1000 m)
Milestone 39: complete (treasures: hats on balloons for the Wardrobe, purple special stars with special perks for the roguelike)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 39: complete`, and every earlier milestone line is still there.
- All tests pass.
