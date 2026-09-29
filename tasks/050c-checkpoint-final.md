---
id: 050c-checkpoint-final
status: ready
tests: [tests/acceptance/test_050c_checkpoint_final.gd]
files: [docs/PROGRESS.md]
read: [scripts/game/main.gd]
---

# Checkpoint 5 (final): a bot finishes the game

All 50 tasks are built. This final test plays the complete game through the real scene and its buttons: from
an empty save, it drags and releases the slingshot, boosts with the Space action when falling, continues from
the results, buys the cheapest upgrade with the shop buttons, and launches again until the 1000 m victory
(within 90 runs; the design target is about 35). It checks that flight and victory music and sound effects
played, that the victory is saved, that every referenced asset exists, and that every script follows the
conventions (class_name, under 300 lines with main.gd under 450, no `print(`, no `get_tree().paused`).

What to do:
1. Append this line to the end of `docs/PROGRESS.md` (keep what is there):
   `Milestone 5: complete (audio and polish: music, sound effects, volume options, shake, popups, upgrade visuals, credits)`
2. If another assertion fails, fix the script it names so it matches docs/DESIGN.md and the task files.
   Do not change balance numbers or costs to make the bot faster.

If the other assertions already pass, the only change needed is the PROGRESS.md line.

## Acceptance criteria
- `docs/PROGRESS.md` contains all five `Milestone N: complete` lines.
- All 55 test scripts pass.
