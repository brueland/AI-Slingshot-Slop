---
id: 014-progress-dict
status: ready
tests: [tests/acceptance/test_014_progress_dict.gd]
files: [scripts/core/progress.gd]
read: [scripts/core/upgrade_catalog.gd]
---

# Progress to and from a dictionary (for saving)

Add two functions to `scripts/core/progress.gd` (keep everything that is there).

```gdscript
func to_dict() -> Dictionary:
	return {
		"version": 1,
		"coins": coins,
		"levels": levels.duplicate(),
		"best_distance": best_distance,
		"total_runs": total_runs,
		"goal_reached": goal_reached,
	}


static func from_dict(data: Dictionary) -> Progress:
	var p := Progress.new()
	...
	return p
```

`from_dict` must accept anything a damaged or old save file could contain. JSON gives every number back as a
float, so convert with `int(...)` / `float(...)`:
- `coins = maxi(0, int(data.get("coins", 0)))`
- `levels`: only if `data.get("levels")` is a Dictionary. For each key: keep it only if
  `UpgradeCatalog.is_valid(str(key))`; level = `clampi(int(value), 0, UpgradeCatalog.max_level(key))`;
  store it only when the level is > 0.
- `best_distance = maxf(0.0, float(data.get("best_distance", 0.0)))`
- `total_runs = maxi(0, int(data.get("total_runs", 0)))`
- `goal_reached = bool(data.get("goal_reached", false))`

## Acceptance criteria
- `to_dict()` holds the values above; changing the returned levels must not change the Progress.
- A JSON round trip gives the same values with int types; `from_dict({})` gives defaults; bad values are repaired.
