---
id: 070c-checkpoint-experience
status: ready
tests: [tests/acceptance/test_070c_checkpoint_experience.gd]
files: [docs/PROGRESS.md]
read: [scripts/game/main.gd, scripts/ui/ui_root.gd]
---

# Checkpoint 7: the player-experience features work together

Milestone 7 (tasks 061-070) is built. This checkpoint's test plays a first session with real frames: the aim hint
on the first shot, the fade finishing by itself, the Liftoff toast appearing and going away after 3 s, the stats
screen showing the run, the best flag on the second shot. It restarts the game from the save file to check lifetime
stats, recent runs and achievements survive, and checks the new scripts' conventions and main.gd's length.

What to do:
1. Append this line to the end of `docs/PROGRESS.md` (keep what is there):
   `Milestone 7: complete (player experience: UI root, fades, hints, best flag, boost flame, stats, achievements, toasts)`
2. If another assertion fails, fix the script it names to match the task files 061-070. If main.gd is too long,
   make its code more compact rather than removing features.

If the other assertions already pass, the only change needed is the PROGRESS.md line.

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 7: complete`.
- All tests pass.
