---
id: 022-main-run-flow
status: ready
tests: [tests/acceptance/test_022_main_run_flow.gd]
files: [scripts/game/main.gd]
read: [scripts/core/run_session.gd, scripts/core/progress.gd, scripts/core/balance.gd]
---

# Main: launch, fly, results, shop, next run

Add the run flow to `scripts/game/main.gd` (keep everything that is there). All of it is plain logic; no
nodes yet.

```gdscript
func _physics_process(delta: float) -> void:
	advance(delta)


func launch_with_pull(pull: Vector2) -> bool:
	if state != State.AIM or pull.length() < Balance.MIN_PULL_PX:
		return false
	session.launch_from_pull(pull)
	change_state(State.FLIGHT)
	return true


func advance(dt: float) -> void:
	if is_paused or state != State.FLIGHT:
		return
	session.step(dt)
	if session.is_finished():
		_finish_run()


func request_boost() -> bool:
	return state == State.FLIGHT and not is_paused and session.boost()


func continue_to_shop() -> void:
	if state == State.RESULTS:
		change_state(State.SHOP)


func buy_upgrade(id: String) -> bool:
	return state == State.SHOP and progress.buy(id)


func leave_shop() -> void:
	if state == State.SHOP:
		_begin_aim()


func _finish_run() -> void:
	last_result = session.result()
	last_result["milestones"] = progress.record_run(last_result["distance"], last_result["coins"])
	change_state(State.RESULTS)
```

`advance(dt)` holds the per-frame logic so tests can step the game without waiting for real frames.

## Acceptance criteria
- Pulls shorter than 10 px, or launching outside AIM, do nothing.
- A full-strength shot goes AIM -> FLIGHT -> RESULTS; `last_result` has the run result plus `milestones`, and
  progress has the coins, 1 run and the best distance.
- In the shop, `buy_upgrade` works; `leave_shop()` starts a fresh session (seed = total_runs + 1) with the new stats.
