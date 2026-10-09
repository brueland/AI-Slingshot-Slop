---
id: 316c-checkpoint-hats-animals
status: ready
tests: [tests/acceptance/test_316c_checkpoint_hats_animals.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 45: hats that help, nicer animals

Milestone 45 (tasks 311-315) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 44: complete (trees and a secret: smash through trees or bounce off them; break the brick wall to find a thank-you sign)
```
REPLACE:
```gdscript
Milestone 44: complete (trees and a secret: smash through trees or bounce off them; break the brick wall to find a thank-you sign)
Milestone 45: complete (hats that help: every hat gives a small boost, shown in the Wardrobe; new sheep and cow sprites)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 45: complete`, and every earlier milestone line is still there.
- All tests pass.
