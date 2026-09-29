---
id: 069-achievements
status: ready
tests: [tests/acceptance/test_069_achievements.gd]
files: [scripts/core/achievements.gd, scripts/core/progress.gd, scripts/game/main.gd]
read: [scripts/core/milestones.gd]
---

# Achievements

**1. Create `scripts/core/achievements.gd`:**
```gdscript
class_name Achievements
extends RefCounted
## One-time achievements, checked after every run. Unlocked ids are saved in Progress.achievements.

const LIST: Array = [
	{"id": "liftoff", "name": "Liftoff", "description": "Finish your first run"},
	{"id": "bouncy", "name": "Bouncy Castle", "description": "Bounce 8 times in one run"},
	{"id": "star_catcher", "name": "Star Catcher", "description": "Collect 5 stars in one run"},
	{"id": "high_flyer", "name": "High Flyer", "description": "Fly higher than 40 m"},
	{"id": "far_out", "name": "Far Out", "description": "Fly 250 m in one run"},
	{"id": "big_spender", "name": "Big Spender", "description": "Own 10 upgrade levels"},
]


static func is_earned(id: String, result: Dictionary, progress: Progress) -> bool:
	match id:
		"liftoff":
			return progress.total_runs >= 1
		"bouncy":
			return int(result.get("bounces", 0)) >= 8
		"star_catcher":
			return int(result.get("stars", 0)) >= 5
		"high_flyer":
			return float(result.get("max_height", 0.0)) > 40.0
		"far_out":
			return float(result.get("distance", 0.0)) >= 250.0
		"big_spender":
			var owned := 0
			for key in progress.levels:
				owned += int(progress.levels[key])
			return owned >= 10
	return false


## Unlocks every achievement this run earned that the player doesn't have yet. Returns their LIST entries.
static func unlock(result: Dictionary, progress: Progress) -> Array:
	var unlocked: Array = []
	for entry in LIST:
		var id: String = entry["id"]
		if not progress.achievements.has(id) and is_earned(id, result, progress):
			progress.achievements.append(id)
			unlocked.append(entry)
	return unlocked
```

**2. `scripts/core/progress.gd`** (keep everything): `var achievements: Array[String] = []`; `to_dict()` also
returns `"achievements": achievements.duplicate()`; `from_dict()`: if `data.get("achievements")` is an Array,
append each value as `str(value)` only if it is an id in `Achievements.LIST` and not already in the list.

**3. `scripts/game/main.gd`:** in `_finish_run()`, after `progress.record_lifetime(last_result)` (before saving):
`last_result["achievements"] = Achievements.unlock(last_result, progress)`.

## Acceptance criteria
- Six achievements with the ids, names and conditions above; each unlocks only once.
- Unlocked ids are saved and loaded; unknown ids and duplicates are dropped; old saves have none.
- The first run in main unlocks Liftoff and lists it in `last_result["achievements"]`.
