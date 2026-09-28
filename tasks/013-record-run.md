---
id: 013-record-run
status: ready
tests: [tests/acceptance/test_013_record_run.gd]
files: [scripts/core/progress.gd]
read: [scripts/core/milestones.gd, scripts/core/balance.gd]
---

# Progress.record_run(): pay for a finished run

Add one function to `scripts/core/progress.gd` (keep everything that is there):

```gdscript
func record_run(distance: float, coins_earned: int) -> Array:
	var reached := Milestones.newly_reached(best_distance, distance)
	add_coins(coins_earned)
	for m in reached:
		add_coins(int(m["reward"]))
	total_runs += 1
	best_distance = maxf(best_distance, distance)
	if distance >= Balance.GOAL_DISTANCE:
		goal_reached = true
	return reached
```

Compute `reached` **before** updating `best_distance`. It returns the milestones this run reached for the
first time (each is paid once, ever).

## Acceptance criteria
- A 60 m run earning 60 coins pays 60 + 25 (First Flight), counts 1 run, and sets best 60.
- A shorter run keeps the best; negative coins are ignored; reaching 1000 m sets `goal_reached`.
