---
id: 312-hats-in-rogue
status: ready
tests: [tests/acceptance/test_312_hats_in_rogue.gd]
files: [scripts/core/rogue_run.gd, scripts/game/main.gd]
---

# Hats in the roguelike

The worn hat's boost (task 311) counts in the roguelike too: `RogueRun.start()` takes the hat (`hat`, kept for the
whole run) and `stats()` applies it; main.gd passes `progress.hat`.

**1. `scripts/core/rogue_run.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 1 adds a variable before the first one; edit 2 adds a parameter to `start()` and a line after its first one; edit 3 adds one line in `stats()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var run_seed: int = 1
```
REPLACE:
```gdscript
## The hat the alien wears in this run (its boost counts: HatBonuses).
var hat: String = "none"
var run_seed: int = 1
```

Edit 2 - SEARCH:
```gdscript
func start(new_seed: int, found: Array = []) -> void:
	run_seed = new_seed
```
REPLACE:
```gdscript
func start(new_seed: int, found: Array = [], worn_hat: String = "none") -> void:
	run_seed = new_seed
	hat = worn_hat
```

Edit 3 - SEARCH:
```gdscript
	s = RogueWeather.apply(StarBoosts.apply(s, star_boosts), weather)
```
REPLACE:
```gdscript
	s = RogueWeather.apply(StarBoosts.apply(s, star_boosts), weather)
	HatBonuses.apply(s, hat)
```

**2. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds `progress.hat` to the `rogue.start` call; nothing else in main.gd changes.

Edit 1 - SEARCH:
```gdscript
randi_range(1, 99999), progress.found)```
REPLACE:
```gdscript
randi_range(1, 99999), progress.found, progress.hat)```

## Acceptance criteria
- `RogueRun.hat` (from `start(seed, found, hat)`) and its boost in `stats()`; main.gd passes the worn hat.
