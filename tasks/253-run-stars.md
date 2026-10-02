---
id: 253-run-stars
status: ready
tests: [tests/acceptance/test_253_run_stars.gd]
files: [scripts/core/rogue_run.gd]
---

# Stars count in the run

Star boosts (task 252) now take effect. A roguelike run counts its stars (`stars_total`) and keeps the boost each
one gave (`star_boosts`). `stats()` applies the boosts (before the weather), so every following shot is a little
better. The shot's outcome lists the boosts it gained and the run's total.

**1. `scripts/core/rogue_run.gd`**: exactly these 5 SEARCH/REPLACE edit(s). Edit 3 changes that line in `stats()`; edit 4 adds the star loop in `finish_shot()` after the `best_shot` line; edit 5 adds two keys to the returned dictionary. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var fight: BossFight = null
```
REPLACE:
```gdscript
var fight: BossFight = null
## Stars collected this run, and the boosts they gave (boost id -> how many; see StarBoosts).
var stars_total: int = 0
var star_boosts: Dictionary = {}
```

Edit 2 - SEARCH:
```gdscript
	goal = RogueGoals.make_goal(1, run_seed)
	fight = null
```
REPLACE:
```gdscript
	goal = RogueGoals.make_goal(1, run_seed)
	fight = null
	stars_total = 0
	star_boosts.clear()
```

Edit 3 - SEARCH:
```gdscript
	s = RogueWeather.apply(s, weather)
```
REPLACE:
```gdscript
	s = RogueWeather.apply(StarBoosts.apply(s, star_boosts), weather)
```

Edit 4 - SEARCH:
```gdscript
	shots += 1
	best_shot = maxf(best_shot, float(result.get("distance", 0.0)))
```
REPLACE:
```gdscript
	shots += 1
	best_shot = maxf(best_shot, float(result.get("distance", 0.0)))
	var stars_gained: Array[String] = []
	for i in int(result.get("stars", 0)):
		stars_total += 1
		var boost := StarBoosts.roll(run_seed, stars_total)
		star_boosts[boost] = int(star_boosts.get(boost, 0)) + 1
		stars_gained.append(boost)
```

Edit 5 - SEARCH:
```gdscript
"shots_left": shots_left}```
REPLACE:
```gdscript
"shots_left": shots_left,
		"stars_gained": stars_gained, "stars_total": stars_total}```

## Acceptance criteria
- `RogueRun.stars_total` and `star_boosts` grow with every star of a shot (`StarBoosts.roll(run_seed, n)` for the n-th star) and reset in `start()`.
- `stats()` includes the boosts; the outcome has `stars_gained` (the boost ids) and `stars_total`.
