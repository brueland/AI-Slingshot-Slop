---
id: 320c-checkpoint-animals
status: ready
tests: [tests/acceptance/test_320c_checkpoint_animals.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 46: the meadow fights back

Milestone 46 (tasks 317-319) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 45: complete (hats that help: every hat gives a small boost, shown in the Wardrobe; new sheep and cow sprites)
```
REPLACE:
```gdscript
Milestone 45: complete (hats that help: every hat gives a small boost, shown in the Wardrobe; new sheep and cow sprites)
Milestone 46: complete (meadow fixes: no endless bonk against a tree; bounce off sheep, get kicked by cows)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 46: complete`, and every earlier milestone line is still there.
- All tests pass.
