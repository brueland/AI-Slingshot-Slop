---
id: 130-rogue-history
status: ready
tests: [tests/acceptance/test_130_rogue_history.gd]
files: [scripts/core/progress.gd, scripts/game/main.gd]
---

# Remember the last roguelike runs

Milestone 15 deepens the roguelike. The last 5 roguelike runs (rounds cleared, seed, number of perks) are
remembered, newest first, and saved.

**1. `scripts/core/progress.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. (Edit 3 adds lines right before the final `return p` of `from_dict()`.)

Edit 1 - SEARCH:
```gdscript
var daily_best: Dictionary = {}
```
REPLACE:
```gdscript
var daily_best: Dictionary = {}
## The last roguelike runs, newest first: {"rounds": int, "seed": int, "perks": int}.
var rogue_history: Array = []

const ROGUE_HISTORY_SIZE: int = 5
```

Edit 2 - SEARCH:
```gdscript
		"daily_best": daily_best.duplicate(),
```
REPLACE:
```gdscript
		"daily_best": daily_best.duplicate(),
		"rogue_history": rogue_history.duplicate(true),
```

Edit 3 - SEARCH:
```gdscript
	return p
```
REPLACE:
```gdscript
	var history_data = data.get("rogue_history")
	if typeof(history_data) == TYPE_ARRAY:
		for item in history_data:
			if typeof(item) == TYPE_DICTIONARY and p.rogue_history.size() < ROGUE_HISTORY_SIZE:
				p.rogue_history.append({"rounds": maxi(0, int(item.get("rounds", 0))), "seed": int(item.get("seed", 0)), "perks": maxi(0, int(item.get("perks", 0)))})
	return p
```

Edit 4 - SEARCH:
```gdscript
func level_of(id: String) -> int:
```
REPLACE:
```gdscript
## Remembers a finished roguelike run (newest first; only the last ROGUE_HISTORY_SIZE are kept).
func add_rogue_run(rounds: int, run_seed: int, perk_count: int) -> void:
	rogue_history.push_front({"rounds": rounds, "seed": run_seed, "perks": perk_count})
	while rogue_history.size() > ROGUE_HISTORY_SIZE:
		rogue_history.pop_back()


func level_of(id: String) -> int:
```

**2. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
			progress.best_rogue_round = maxi(progress.best_rogue_round, rogue.rounds_cleared)
```
REPLACE:
```gdscript
			progress.best_rogue_round = maxi(progress.best_rogue_round, rogue.rounds_cleared)
			progress.add_rogue_run(rogue.rounds_cleared, rogue.run_seed, rogue.perks.size())
```

## Acceptance criteria
- `Progress.add_rogue_run(rounds, seed, perks)` keeps the newest 5 runs, newest first; they are saved and loaded.
- A roguelike run that ends is added to the history.
