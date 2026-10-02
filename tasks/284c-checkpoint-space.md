---
id: 284c-checkpoint-space
status: ready
tests: [tests/acceptance/test_284c_checkpoint_space.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 40: space

Milestone 40 (tasks 282-283) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 39: complete (treasures: hats on balloons for the Wardrobe, purple special stars with special perks for the roguelike)
```
REPLACE:
```gdscript
Milestone 39: complete (treasures: hats on balloons for the Wardrobe, purple special stars with special perks for the roguelike)
Milestone 40: complete (space: a satellite, a ringed planet and a moon, comets, asteroids and an astronaut high above the meadow)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 40: complete`, and every earlier milestone line is still there.
- All tests pass.
