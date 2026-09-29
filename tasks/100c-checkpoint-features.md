---
id: 100c-checkpoint-features
status: ready
tests: [tests/acceptance/test_100c_checkpoint_features.gd]
files: [docs/PROGRESS.md]
read: [scripts/game/main.gd]
---

# Checkpoint 10: the new features work together

Milestone 10 (tasks 091-100) is built. This checkpoint's test plays with real frames: a strong classic shot
(dragged with the mouse API) pops a balloon while the pause menu pauses and resumes the flight, the next shot shows
the best run's ghost and the R key repeats the same launch; a daily run rerolls its perks and picks one; the title
mascot bobs wearing its hat. It also checks the new scripts' conventions and main.gd's length.

What to do:
1. Append this line to the end of `docs/PROGRESS.md` (keep what is there):
   `Milestone 10: complete (features: balloons, best-run ghost, repeat shot, daily run, rerolls, pause menu, title mascot, night stars)`
2. If another assertion fails, fix the script it names to match the task files 091-100. If main.gd is too long,
   make its code more compact rather than removing features.

If the other assertions already pass, the only change needed is the PROGRESS.md line.

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 10: complete`.
- All tests pass.
