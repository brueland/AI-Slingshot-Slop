---
id: 110-rogue-weather
status: ready
tests: [tests/acceptance/test_110_rogue_weather.gd]
files: [scripts/core/rogue_weather.gd, scripts/core/rogue_run.gd]
read: [scripts/core/rogue_perks.gd]
---

# Roguelike weather

From round 3 every roguelike round has a weather that changes the shot a little (Tailwind, Headwind, Thick Air,
Springy Ground, Soggy Ground, or Calm), so the size and perk choice also depends on the weather. The same run seed
and round always give the same weather; a retry keeps it.

**1. Create the file `scripts/core/rogue_weather.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name RogueWeather
extends RefCounted
## Roguelike weather: from round FROM_ROUND on, every round has one, which changes the shot a little. The same run
## seed and round always give the same weather (a retry keeps it).

const FROM_ROUND: int = 3
const LIST: Array = [
	{"id": "calm", "name": "Calm", "description": "no change", "speed": 1.0, "drag": 1.0, "bounce": 0.0},
	{"id": "tailwind", "name": "Tailwind", "description": "+8% launch speed", "speed": 1.08, "drag": 1.0, "bounce": 0.0},
	{"id": "headwind", "name": "Headwind", "description": "-8% launch speed", "speed": 0.92, "drag": 1.0, "bounce": 0.0},
	{"id": "thick_air", "name": "Thick Air", "description": "+50% air drag", "speed": 1.0, "drag": 1.5, "bounce": 0.0},
	{"id": "springy", "name": "Springy Ground", "description": "+0.1 bounciness", "speed": 1.0, "drag": 1.0, "bounce": 0.1},
	{"id": "soggy", "name": "Soggy Ground", "description": "-0.1 bounciness", "speed": 1.0, "drag": 1.0, "bounce": -0.1},
]


static func get_def(id: String) -> Dictionary:
	for entry in LIST:
		if entry["id"] == id:
			return entry
	return {}


## The weather of a round: "calm" before FROM_ROUND, else picked by a generator seeded with the run seed and round.
static func for_round(round_number: int, run_seed: int) -> String:
	if round_number < FROM_ROUND:
		return "calm"
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed * 31 + round_number * 7
	var entry: Dictionary = LIST[rng.randi_range(0, LIST.size() - 1)]
	return entry["id"]


## Applies weather `id` to `stats` (in place) and returns them. Unknown ids count as "calm".
static func apply(stats: PlayerStats, id: String) -> PlayerStats:
	var d := get_def(id)
	if d.is_empty():
		d = get_def("calm")
	stats.max_speed *= float(d["speed"])
	stats.drag *= float(d["drag"])
	stats.restitution = clampf(stats.restitution + float(d["bounce"]), RoguePerks.MIN_RESTITUTION, RoguePerks.MAX_RESTITUTION)
	return stats
```

**2. `scripts/core/rogue_run.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var size_id: String = "normal"
```
REPLACE:
```gdscript
var size_id: String = "normal"
var weather: String = "calm"
```

Edit 2 - SEARCH:
```gdscript
	size_id = "normal"
	perks.clear()
```
REPLACE:
```gdscript
	size_id = "normal"
	weather = RogueWeather.for_round(1, new_seed)
	perks.clear()
```

Edit 3 - SEARCH:
```gdscript
	return RogueSizes.apply(RoguePerks.apply(PlayerStats.from_levels({}), perks), size_id)
```
REPLACE:
```gdscript
	var s := RogueSizes.apply(RoguePerks.apply(PlayerStats.from_levels({}), perks), size_id)
	return RogueWeather.apply(s, weather)
```

Edit 4 - SEARCH:
```gdscript
		goal = RogueGoals.make_goal(round_number, run_seed)
```
REPLACE:
```gdscript
		goal = RogueGoals.make_goal(round_number, run_seed)
		weather = RogueWeather.for_round(round_number, run_seed)
```

## Acceptance criteria
- Six weathers with the effects above; rounds 1-2 are calm; the same seed and round give the same weather.
- `apply` changes launch speed, drag and bounciness (kept within 0.1-0.9); unknown ids count as calm.
- RogueRun starts calm, rolls a new weather when a round is cleared, keeps it on a retry, and `stats()` includes it.
