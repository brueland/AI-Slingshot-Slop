---
id: 300c-checkpoint-endless
status: ready
tests: [tests/acceptance/test_300c_checkpoint_endless.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 42: endless and smooth

Milestone 42 (tasks 289-299) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 41: complete (wrong way: WRONG WAY signs behind the slingshot and a giant brick wall that bonks the alien back)
```
REPLACE:
```gdscript
Milestone 41: complete (wrong way: WRONG WAY signs behind the slingshot and a giant brick wall that bonks the alien back)
Milestone 42: complete (endless and smooth: the HUD box keeps its width, the course and the meadow go on forever, only what is on screen is drawn, the ground, the night stars and the flowers are one draw call each, the Wardrobe fits, a Menu button on the perk screen, no useless upgrade levels)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 42: complete`, and every earlier milestone line is still there.
- All tests pass.
