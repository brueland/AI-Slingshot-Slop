---
id: 060c-checkpoint-polish
status: ready
tests: [tests/acceptance/test_060c_checkpoint_polish.gd]
files: [docs/PROGRESS.md]
read: [scripts/game/main.gd, scripts/game/effects.gd]
---

# Checkpoint 6: the visual polish works together

Milestone 6 (tasks 051-060) is built. This checkpoint's test plays a flight with real frames and checks that
all the polish works together: the trail fills up, bounces puff dust, the shadow stays under the projectile,
every particle effect frees itself after it finishes (nothing piles up), every UI control uses the theme, and the
world layers are drawn in order (background, ground, scenery, course items, trail, shadow, projectile,
effects). It also checks the new scripts' conventions (class_name, under 300 lines, no `print(`) and that
main.gd stays under 450 lines.

What to do:
1. Append this line to the end of `docs/PROGRESS.md` (keep what is there):
   `Milestone 6: complete (graphics polish: UI theme, solid ground, scenery, trail, shadow, particles, sky tint, slingshot)`
2. If another assertion fails, fix the script it names to match the task files 051-060. If main.gd is too long,
   make its new code more compact rather than removing features.

If the other assertions already pass, the only change needed is the PROGRESS.md line.

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 6: complete`.
- All tests pass, including the regression test that keeps every menu on screen.
