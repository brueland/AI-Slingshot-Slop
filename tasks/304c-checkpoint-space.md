---
id: 304c-checkpoint-space
status: ready
tests: [tests/acceptance/test_304c_checkpoint_space.gd]
files: [docs/PROGRESS.md]
---

# Checkpoint 43: space to play with

Milestone 43 (tasks 301-303) is built and its tests pass; this checkpoint's test plays its features together.
The scripts are finished: do not open, add to the chat, or edit any other file (not the scripts, not the tests).
Only if the test output after this change names a failing assertion should you fix the one script it names.

**1. `docs/PROGRESS.md`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the new line after the last milestone line; every line already in the file stays.

Edit 1 - SEARCH:
```gdscript
Milestone 42: complete (endless and smooth: the HUD box keeps its width, the course and the meadow go on forever, only what is on screen is drawn, the ground, the night stars and the flowers are one draw call each, the Wardrobe fits, a Menu button on the perk screen, no useless upgrade levels)
```
REPLACE:
```gdscript
Milestone 42: complete (endless and smooth: the HUD box keeps its width, the course and the meadow go on forever, only what is on screen is drawn, the ground, the night stars and the flowers are one draw call each, the Wardrobe fits, a Menu button on the perk screen, no useless upgrade levels)
Milestone 43: complete (space to play with: meteors boost the alien, space stations bounce it, a thick star cloud from 600 m up)
```

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 43: complete`, and every earlier milestone line is still there.
- All tests pass.
