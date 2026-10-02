class_name StarBoosts
extends RefCounted
## Roguelike star power: every star collected in a run gives a small random boost for the rest of the run. The same
## run seed gives the same boosts in the same order (the n-th star of a run always gives the same one).

const LIST: Array = [
	{"id": "speed", "name": "Speed+", "description": "+2% launch speed"},
	{"id": "glide", "name": "Glide+", "description": "-3% air drag"},
	{"id": "bounce", "name": "Bounce+", "description": "+0.015 bounciness"},
	{"id": "lift", "name": "Lift+", "description": "+0.2 m launch height"},
]


static func get_def(id: String) -> Dictionary:
	for entry in LIST:
		if entry["id"] == id:
			return entry
	return {}


## The boost of the `star_number`-th star of a run (1 = the first).
static func roll(run_seed: int, star_number: int) -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed * 7907 + star_number * 104729
	return str(LIST[rng.randi_range(0, LIST.size() - 1)]["id"])


## Applies `boosts` (boost id -> how many) to `stats` in place and returns them.
static func apply(stats: PlayerStats, boosts: Dictionary) -> PlayerStats:
	stats.max_speed *= pow(1.02, int(boosts.get("speed", 0)))
	stats.drag *= pow(0.97, int(boosts.get("glide", 0)))
	stats.restitution = minf(stats.restitution + 0.015 * int(boosts.get("bounce", 0)), RoguePerks.MAX_RESTITUTION)
	stats.launch_height += 0.2 * int(boosts.get("lift", 0))
	return stats


## "Speed+ x2, Lift+ x1" for `ids` (one id per star, in order; repeats are counted).
static func summary(ids: Array) -> String:
	var counts := {}
	var order: Array[String] = []
	for id in ids:
		if not counts.has(id):
			order.append(id)
		counts[id] = int(counts.get(id, 0)) + 1
	var parts := PackedStringArray()
	for id in order:
		parts.append("%s x%d" % [get_def(id).get("name", id), counts[id]])
	return ", ".join(parts)
