---
id: 288c-checkpoint-wrong-way
status: ready
tests: [tests/acceptance/test_288c_checkpoint_wrong_way.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 41: wrong way

Milestone 41 (tasks 285-287) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 40: complete (space: a satellite, a ringed planet and a moon, comets, asteroids and an astronaut high above the meadow)
```
REPLACE:
```gdscript
Milestone 40: complete (space: a satellite, a ringed planet and a moon, comets, asteroids and an astronaut high above the meadow)
Milestone 41: complete (wrong way: WRONG WAY signs behind the slingshot and a giant brick wall that bonks the alien back)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 41: complete`, and every earlier milestone line is still there.
- All tests pass.
