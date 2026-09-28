---
id: 010c-checkpoint-core
status: ready
tests: [tests/acceptance/test_010c_checkpoint_core.gd]
files: [docs/PROGRESS.md]
read: [scripts/core/balance.gd, scripts/core/launch_math.gd, scripts/core/flight_sim.gd, scripts/core/player_stats.gd, scripts/core/scoring.gd]
---

# Checkpoint 1: core simulation works end to end

Milestone 1 (tasks 001-010) is built. This checkpoint's test runs real shots through all the core classes
together: launch math -> FlightSim with PlayerStats -> Scoring. It checks that a shot with no upgrades flies
40-70 m, that every distance upgrade and boosts make shots longer, that a fully upgraded shot passes 700 m,
and that each core script follows the project conventions (class_name, extends RefCounted, under 300 lines,
no `print(`).

What to do:
1. Append this line to the end of `docs/PROGRESS.md` (keep what is there):
   `Milestone 1: complete (core simulation: balance, launch math, flight sim, upgrades, stats, scoring)`
2. If any other assertion in the test fails, fix the core script it names so it matches docs/DESIGN.md
   (sections 3, 4, 5, 7 and 9). Do not change numbers in `balance.gd` to make a test pass; find the logic bug.

If the other assertions already pass, the only change needed is the PROGRESS.md line.

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 1: complete`.
- All milestone 1 tests and this checkpoint's integration tests pass.
