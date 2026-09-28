---
id: 020c-checkpoint-progression
status: ready
tests: [tests/acceptance/test_020c_checkpoint_progression.gd]
files: [docs/PROGRESS.md]
read: [scripts/core/progress.gd, scripts/core/run_session.gd, scripts/core/run_tracker.gd, scripts/core/course_generator.gd, scripts/core/save_system.gd, scripts/core/milestones.gd]
---

# Checkpoint 2: the progression loop works headlessly

Milestone 2 (tasks 011-020) is built. This checkpoint's test plays the game without any scenes: a bot fires
full-strength 45 degree shots (boosting when falling), records each run, buys the cheapest upgrade it can
afford, and repeats. It must reach 1000 m in 12-90 runs (the design target is about 35), with the first run
at 40-75 m and every milestone paid exactly once. It also checks save/load of the final progress and the
conventions of the milestone 2 scripts.

What to do:
1. Append this line to the end of `docs/PROGRESS.md` (keep what is there):
   `Milestone 2: complete (progression: coins, milestones, saving, course, tracker, run session)`
2. If any other assertion fails, fix the script it points to so it matches docs/DESIGN.md. Do not change
   balance numbers or upgrade costs to make the bot faster or slower; find the logic bug instead (for
   example a spring that triggers every frame, or milestones paid twice).

If the other assertions already pass, the only change needed is the PROGRESS.md line.

## Acceptance criteria
- `docs/PROGRESS.md` contains `Milestone 2: complete`.
- All tests so far pass, including the bot's balance check.
