---
id: 310c-checkpoint-secret
status: ready
tests: [tests/acceptance/test_310c_checkpoint_secret.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 44: trees and a secret

Milestone 44 (tasks 305-309) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 43: complete (space to play with: meteors boost the alien, space stations bounce it, a thick star cloud from 600 m up)
```
REPLACE:
```gdscript
Milestone 43: complete (space to play with: meteors boost the alien, space stations bounce it, a thick star cloud from 600 m up)
Milestone 44: complete (trees and a secret: smash through trees or bounce off them; break the brick wall to find a thank-you sign)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 44: complete`, and every earlier milestone line is still there.
- All tests pass.
