---
id: 040c-checkpoint-loop
status: ready
tests: [tests/acceptance/test_040c_checkpoint_loop.gd]
files: [docs/PROGRESS.md]
read: [scripts/game/main.gd, scripts/ui/shop_panel.gd, scripts/ui/title_panel.gd]
---

# Checkpoint 4: the full game loop through the UI

Milestone 4 (tasks 031-040) is built. This checkpoint's test plays the game the way a player does, with real
frames: Play on the title screen, drag and release the slingshot, Continue on the results, buy Aim Guide in the
shop, Launch! and fly again. It also restarts the game from the save file, pauses during a flight, reaches the
1000 m victory with maxed upgrades, and checks the UI conventions (class_name, under 300 lines, no `print(`,
main.gd under 450 lines, no `get_tree().paused`, HUD ignores the mouse).

What to do:
1. Append this line to the end of `docs/PROGRESS.md` (keep what is there):
   `Milestone 4: complete (game loop UI: HUD, results, shop, save/load, title, victory, pause, background)`
2. If another assertion fails, fix the script it names to match docs/DESIGN.md and the task files 031-040.

If the other assertions already pass, the only change needed is the PROGRESS.md line.

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 4: complete`.
- All tests so far pass.
