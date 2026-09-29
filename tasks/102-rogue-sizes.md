---
id: 102-rogue-sizes
status: ready
tests: [tests/acceptance/test_102_rogue_sizes.gd]
files: [scripts/core/rogue_sizes.gd, scripts/core/rogue_run.gd]
read: [scripts/core/player_stats.gd, scripts/core/rogue_perks.gd]
---

# Alien sizes for the roguelike

Between roguelike shots the player picks the alien's size. Big is a little slower with more drag but reaches stars
easily; Small flies faster and farther but must fly closer to a star. In the roguelike stars are picked up by the
alien's body (its radius + 0.9 m around its center), so rolling into a low star counts.

**1. Create the file `scripts/core/rogue_sizes.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name RogueSizes
extends RefCounted
## Alien sizes for the roguelike, picked between shots. Bigger is slower with more drag but reaches stars easily;
## smaller flies faster and farther but has to fly closer to a star. In the roguelike a star is picked up by the
## alien's body: within (its radius + STAR_REACH) of its center, so rolling into a low star counts too.

const STAR_REACH: float = 0.9
const LIST: Array = [
	{"id": "small", "name": "Small", "scale": 0.6, "speed": 1.15, "drag": 0.65,
		"description": "faster and farther, harder to hit stars"},
	{"id": "normal", "name": "Normal", "scale": 1.0, "speed": 1.0, "drag": 1.0, "description": "balanced"},
	{"id": "big", "name": "Big", "scale": 2.5, "speed": 0.95, "drag": 1.3,
		"description": "a little slower, more drag, easy to hit stars"},
]


static func get_def(id: String) -> Dictionary:
	for entry in LIST:
		if entry["id"] == id:
			return entry
	return {}


## Applies size `id` to `stats` (in place) and returns them. Unknown ids count as "normal".
static func apply(stats: PlayerStats, id: String) -> PlayerStats:
	var d := get_def(id)
	if d.is_empty():
		d = get_def("normal")
	var s: float = d["scale"]
	stats.size_scale = s
	stats.max_speed *= float(d["speed"])
	stats.drag *= float(d["drag"])
	var body := Balance.PROJECTILE_RADIUS * s
	stats.pickup_offset = body
	stats.pickup_radius = body + STAR_REACH
	return stats
```

**2. `scripts/core/rogue_run.gd`** (keep everything else; small SEARCH/REPLACE edits):
- **Declare the variable** at the top of the class, on the line right after `var rerolls: int = 1`:
  ```gdscript
  var size_id: String = "normal"
  ```
- In `start()`, right after `rerolls = 1`: `size_id = "normal"`
- `stats()` becomes:
  ```gdscript
  func stats() -> PlayerStats:
  	return RogueSizes.apply(RoguePerks.apply(PlayerStats.from_levels({}), perks), size_id)
  ```
- Add this function right before `has_perk()`:
  ```gdscript
  ## The alien's size for the next shots ("small", "normal" or "big"); it stays until changed.
  func set_size(id: String) -> bool:
  	if RogueSizes.get_def(id).is_empty():
  		return false
  	size_id = id
  	return true
  ```

## Acceptance criteria
- Sizes small / normal / big with the numbers above; unknown ids count as normal.
- Roguelike stats always measure pickups from the body (normal: offset 0.75 m, radius 1.65 m).
- A run starts normal, keeps a chosen size until changed, and ignores unknown sizes.
