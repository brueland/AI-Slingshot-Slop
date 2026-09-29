---
id: 105c-checkpoint-sizes
status: ready
tests: [tests/acceptance/test_105c_checkpoint_sizes.gd]
files: [docs/PROGRESS.md]
read: [scripts/core/rogue_sizes.gd, scripts/core/rogue_run.gd]
---

# Checkpoint 11: sizes make star goals fair

Milestone 11 (tasks 101-104) is built. This checkpoint's test lets a bot play a seeded roguelike run through the UI
with real frames. Before every shot it picks, on the perk panel, the size that can meet the next goal (Big for
stars, Small for distance), checked by simulating RunSession exactly like the game. It must meet every star goal,
clear more than 7 rounds, and every shot must play out as predicted. It also checks that rolling into a low star
counts in the roguelike but not in classic, and the conventions.

What to do:
1. Append this line to the end of `docs/PROGRESS.md` (keep what is there):
   `Milestone 11: complete (roguelike sizes: small, normal and big aliens; stars picked up by the alien's body)`
2. If another assertion fails, fix the script it names to match the task files 101-104.

If the other assertions already pass, the only change needed is the PROGRESS.md line.

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 11: complete`.
- All tests pass.
