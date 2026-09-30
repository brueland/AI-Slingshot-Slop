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
