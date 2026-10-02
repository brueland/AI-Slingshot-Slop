---
id: 275-finds
status: ready
tests: [tests/acceptance/test_275_finds.gd, tests/acceptance/test_083_hats.gd, tests/acceptance/test_085_wardrobe.gd, tests/acceptance/test_112_rogue_stats.gd]
files: [scripts/core/progress.gd, scripts/core/hats.gd, scripts/game/main.gd]
---

# Finds are kept

Milestone 39 hides treasures in the world: hats carried by balloons and special perks in purple stars. This task
keeps what is found for good: `Progress.found` (saved), `add_finds(result)` (a shot's result lists its finds under
"found"), three new hats that unlock when found, and main.gd keeps every shot's finds when it ends (and saves).
The next tasks put the treasures in the world. Three older tests are updated for the three new hats.

**1. `scripts/core/progress.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edits 2 and 3 add `found` to the save and the load; edit 4 adds `add_finds()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var best_air_time: float = 0.0
```
REPLACE:
```gdscript
var best_air_time: float = 0.0
## Things found in the world for good: balloon hats and special perks (ids).
var found: Array[String] = []
```

Edit 2 - SEARCH:
```gdscript
		"best_air_time": best_air_time,
	}
```
REPLACE:
```gdscript
		"best_air_time": best_air_time,
		"found": found.duplicate(),
	}
```

Edit 3 - SEARCH:
```gdscript
	p.best_air_time = maxf(0.0, float(data.get("best_air_time", 0.0)))
```
REPLACE:
```gdscript
	p.best_air_time = maxf(0.0, float(data.get("best_air_time", 0.0)))
	var found_data = data.get("found")
	if typeof(found_data) == TYPE_ARRAY:
		for id in found_data:
			if not p.found.has(str(id)):
				p.found.append(str(id))
```

Edit 4 - SEARCH:
```gdscript
	recent_distances.append(float(result.get("distance", 0.0)))
	while recent_distances.size() > RECENT_RUNS:
		recent_distances.pop_front()
```
REPLACE:
```gdscript
	recent_distances.append(float(result.get("distance", 0.0)))
	while recent_distances.size() > RECENT_RUNS:
		recent_distances.pop_front()


## Keeps what a shot found (its result's "found" ids); returns the ids that are new.
func add_finds(result: Dictionary) -> Array[String]:
	var new_ids: Array[String] = []
	for id in result.get("found", []):
		if not found.has(str(id)):
			found.append(str(id))
			new_ids.append(str(id))
	return new_ids
```

**2. `scripts/core/hats.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	{"id": "crown", "name": "Crown", "hint": "Reach 1000 m"},
```
REPLACE:
```gdscript
	{"id": "crown", "name": "Crown", "hint": "Reach 1000 m"},
	{"id": "cowboy", "name": "Cowboy Hat", "hint": "Pop the balloon carrying it"},
	{"id": "viking", "name": "Viking Helmet", "hint": "Pop the balloon carrying it"},
	{"id": "beanie", "name": "Bobble Beanie", "hint": "Pop the balloon carrying it"},
```

Edit 2 - SEARCH:
```gdscript
		"crown":
			return progress.goal_reached
	return false
```
REPLACE:
```gdscript
		"crown":
			return progress.goal_reached
		"cowboy", "viking", "beanie":
			return progress.found.has(id)
	return false
```

**3. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds two lines at the start of `_finish_run()`; nothing else in main.gd changes (it must stay under 450 lines).

Edit 1 - SEARCH:
```gdscript
	var hats_before := Hats.unlocked(progress)
```
REPLACE:
```gdscript
	var hats_before := Hats.unlocked(progress)
	if not progress.add_finds(session.result()).is_empty():
		save_progress()
```

## Acceptance criteria
- `Progress.found` is saved; `add_finds(result)` adds the result's new "found" ids and returns them.
- Hats `cowboy`, `viking` and `beanie` are unlocked once found; every finished shot's finds are kept.
