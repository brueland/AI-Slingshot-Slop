---
id: 030c-checkpoint-scene
status: ready
tests: [tests/acceptance/test_030c_checkpoint_scene.gd]
files: [docs/PROGRESS.md]
read: [scripts/game/main.gd, scripts/game/slingshot.gd, scripts/game/course_view.gd]
---

# Checkpoint 3: the scene plays a run with real frames

Milestone 3 (tasks 021-030) is built. Until now tests called functions directly; this checkpoint's test lets
real frames run, so every `_draw()` and `_physics_process()` executes. It plays a full run through the
slingshot, checks the state sequence AIM -> FLIGHT -> RESULTS, checks that the second run is wired to its new
session, and checks conventions: each game script has its `class_name`, stays under 300 lines and never
prints, and `scenes/main.tscn` is the only scene.

What to do:
1. Append this line to the end of `docs/PROGRESS.md` (keep what is there):
   `Milestone 3: complete (playable scene: state machine, world, slingshot, preview, camera, course sprites)`
2. If another assertion fails, the test output names the script: fix it to match docs/DESIGN.md. Common
   causes: an error inside a `_draw()` function (wrong argument types), a signal connected to the previous
   run's tracker, or an extra `.tscn` file (build nodes in code instead and delete it).

If the other assertions already pass, the only change needed is the PROGRESS.md line.

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 3: complete`.
- All tests so far pass with real frames running.
