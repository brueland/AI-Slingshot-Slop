---
id: 080c-checkpoint-roguelike
status: ready
tests: [tests/acceptance/test_080c_checkpoint_roguelike.gd]
files: [docs/PROGRESS.md]
read: [scripts/game/main.gd, scripts/core/rogue_run.gd]
---

# Checkpoint 8: the roguelike mode works end to end

Milestone 8 (tasks 071-080) is built. This checkpoint's test lets a bot play a seeded roguelike run through the UI
with real frames: it searches for an aim that meets each goal (simulating a RunSession with the run's stats and
course, exactly like the game), drags the slingshot, and picks the perk that helps most with the next goal. It must
clear at least 5 rounds, and every shot must play out exactly as predicted. It also loses a run on purpose (run-over
screen, best round saved across a restart), checks that classic mode is unchanged afterwards, and checks the new
scripts' conventions and main.gd's length.

What to do:
1. Append this line to the end of `docs/PROGRESS.md` (keep what is there):
   `Milestone 8: complete (roguelike mode: goals, perks, lives, perk and run-over screens, last-aim line)`
2. If another assertion fails, fix the script it names to match the task files 071-080. If a shot does not play
   out as predicted, check that `_begin_aim()` uses `rogue.stats()` and `rogue.shot_seed()` in the roguelike.
   If main.gd is too long, make its code more compact rather than removing features.

If the other assertions already pass, the only change needed is the PROGRESS.md line.

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 8: complete`.
- All tests pass.
