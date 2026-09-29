---
id: 083-hats
status: ready
tests: [tests/acceptance/test_083_hats.gd]
files: [scripts/core/hats.gd, scripts/core/progress.gd]
---

# Hats for the alien (unlock rules and saving)

Milestone 9 adds whimsy. The alien can wear a hat; hats unlock by playing and never change the physics. This
task adds the list and the rules; tasks 084-086 draw them, add a Wardrobe screen and announce new hats.

**1. Create `scripts/core/hats.gd` with exactly this code:**
```gdscript
class_name Hats
extends RefCounted
## Cosmetic hats for the alien. Each one unlocks by playing; hats never change the physics.

const LIST: Array = [
	{"id": "none", "name": "No hat", "hint": ""},
	{"id": "party", "name": "Party Hat", "hint": "Finish your first run"},
	{"id": "propeller", "name": "Propeller Cap", "hint": "Fly 100 m"},
	{"id": "chef", "name": "Chef's Toque", "hint": "Collect 25 stars in total"},
	{"id": "top_hat", "name": "Top Hat", "hint": "Own 10 upgrade levels"},
	{"id": "wizard", "name": "Wizard Hat", "hint": "Clear 5 roguelike rounds"},
	{"id": "crown", "name": "Crown", "hint": "Reach 1000 m"},
]


static func get_def(id: String) -> Dictionary:
	for entry in LIST:
		if entry["id"] == id:
			return entry
	return {}


static func is_unlocked(id: String, progress: Progress) -> bool:
	match id:
		"none":
			return true
		"party":
			return progress.total_runs >= 1
		"propeller":
			return progress.best_distance >= 100.0
		"chef":
			return int(progress.lifetime.get("stars", 0)) >= 25
		"top_hat":
			var owned := 0
			for key in progress.levels:
				owned += int(progress.levels[key])
			return owned >= 10
		"wizard":
			return progress.best_rogue_round >= 5
		"crown":
			return progress.goal_reached
	return false


## The ids of every unlocked hat, in LIST order.
static func unlocked(progress: Progress) -> Array[String]:
	var ids: Array[String] = []
	for entry in LIST:
		var id: String = entry["id"]
		if is_unlocked(id, progress):
			ids.append(id)
	return ids


## Hats unlocked now that were not in `before` (a list from unlocked()).
static func newly_unlocked(before: Array, progress: Progress) -> Array[String]:
	var ids: Array[String] = []
	for id in unlocked(progress):
		if not before.has(id):
			ids.append(id)
	return ids
```

**2. `scripts/core/progress.gd`** (keep everything else):
- **Declare the variable** right after `var recent_distances ...` (without it the script fails with
  `Identifier "hat" not declared in the current scope`):
  ```gdscript
  var hat: String = "none"
  ```
- `to_dict()`: add `"hat": hat,` to the returned Dictionary.
- `from_dict()`: right before the final `return p`, add:
  ```gdscript
  	var hat_id := str(data.get("hat", "none"))
  	if not Hats.get_def(hat_id).is_empty():
  		p.hat = hat_id
  ```

## Acceptance criteria
- Seven hats with the ids, names and unlock rules above; "none" is always unlocked.
- `unlocked()` lists unlocked ids in LIST order; `newly_unlocked(before, progress)` lists the new ones.
- `Progress.hat` is saved and loaded; old saves and unknown ids give "none".
