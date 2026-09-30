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
