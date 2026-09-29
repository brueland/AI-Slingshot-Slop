---
id: 090c-checkpoint-whimsy
status: ready
tests: [tests/acceptance/test_090c_checkpoint_whimsy.gd]
files: [docs/PROGRESS.md]
read: [scripts/game/main.gd, scripts/game/projectile_view.gd]
---

# Checkpoint 9: the whimsy features work together

Milestone 9 (tasks 081-090) is built. This checkpoint's test plays a first session with real frames: the Party Hat
is locked, the first shot (dragged with the mouse API) bounces and wobbles the alien with its decor upright, the
alien ends sleepy, the results announce the Party Hat, a new best throws confetti and the results screen quotes the
alien. Then it puts the hat on in the Wardrobe and restarts to check it stays on. It also wakes a sheep with real
frames, and checks the new scripts' conventions and main.gd's length.

What to do:
1. Append this line to the end of `docs/PROGRESS.md` (keep what is there):
   `Milestone 9: complete (whimsy: hats and wardrobe, jelly wobble, moods, sheep, confetti, quips)`
2. If another assertion fails, fix the script it names to match the task files 081-090. If main.gd is too long,
   make its code more compact rather than removing features.

If the other assertions already pass, the only change needed is the PROGRESS.md line.

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 9: complete`.
- All tests pass.
