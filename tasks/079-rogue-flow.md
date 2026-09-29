---
id: 079-rogue-flow
status: ready
tests: [tests/acceptance/test_079_rogue_flow.gd]
files: [scripts/game/main.gd]
read: [scripts/core/rogue_run.gd, scripts/core/run_session.gd]
---

# main.gd runs the roguelike mode

main.gd gets a second mode. The state enum does **not** change (tests pin its exact keys): a roguelike shot uses
AIM and FLIGHT like a classic one, and after the shot main goes to RESULTS, where (task 080) the perk panel is
shown instead of the classic results panel. Classic progress (coins, runs, milestones, achievements) is not
touched by roguelike shots. Keep main.gd short: only the edits below.

**`scripts/game/main.gd`:**

1. **Declare the variables** right after `var is_paused: bool = false` (without them the script fails with
   `Identifier "mode" not declared in the current scope`):
   ```gdscript
   var mode: String = "classic"        # "classic" or "rogue"
   var rogue: RogueRun
   var rogue_outcome: Dictionary = {}
   ```
2. Add these two functions right after `start_game()`:
   ```gdscript
   func start_rogue(run_seed: int = 0) -> void:
   	if state != State.TITLE:
   		return
   	mode = "rogue"
   	rogue = RogueRun.new()
   	rogue.start(run_seed if run_seed > 0 else randi_range(1, 99999))
   	_begin_aim()


   func choose_rogue_perk(id: String) -> bool:
   	if mode != "rogue" or state != State.RESULTS or not rogue.choose_perk(id):
   		return false
   	_begin_aim()
   	return true
   ```
3. In `_begin_aim()`, replace the line `session = RunSession.new(progress.stats(), progress.total_runs + 1)` with:
   ```gdscript
   	if mode == "rogue":
   		session = RunSession.new(rogue.stats(), rogue.shot_seed())
   	else:
   		session = RunSession.new(progress.stats(), progress.total_runs + 1)
   ```
   and replace the line `slingshot.show_last_aim = progress.level_of("guide") >= 1` with:
   ```gdscript
   	slingshot.show_last_aim = rogue.has_perk("steady") if mode == "rogue" else progress.level_of("guide") >= 1
   ```
4. At the very start of `_finish_run()` (before `var previous_best`), add:
   ```gdscript
   	if mode == "rogue":
   		last_result = session.result()
   		rogue_outcome = rogue.finish_shot(last_result)
   		if rogue.is_over():
   			progress.best_rogue_round = maxi(progress.best_rogue_round, rogue.rounds_cleared)
   			save_progress()
   		change_state(State.RESULTS)
   		return
   ```
5. In `_update_ui()`, the classic results panel is only for classic mode - change the condition
   `if state == State.RESULTS:` (the one that calls `results_panel.show_result(...)`) to:
   ```gdscript
   	if state == State.RESULTS and mode == "classic":
   ```
6. In `go_to_title()`, add `mode = "classic"` as the first line.

## Acceptance criteria
- `mode` is "classic" by default; `start_rogue(7)` (only from TITLE) starts a run with seed 7 in AIM, on the
  course `rogue.shot_seed()`, with the run's stats (classic upgrades are ignored); `start_rogue()` picks a
  random seed > 0; `go_to_title()` goes back to classic.
- A finished roguelike shot is scored by `rogue.finish_shot` (stored in `rogue_outcome`), goes to RESULTS, and
  does not count classic runs or coins; the classic results panel stays hidden.
- `choose_rogue_perk(id)` accepts only an offered perk in RESULTS and starts the next shot.
- Steady Hand turns on the last-aim line in the roguelike; when the run is over the best round is saved.
