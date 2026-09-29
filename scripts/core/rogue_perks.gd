class_name RoguePerks
extends RefCounted
## Perks for the roguelike mode. The player picks one of three after every shot; they stack with no cap.

const LIST: Array = [
	{"id": "power", "name": "Stronger Bands", "description": "+15% launch speed"},
	{"id": "height", "name": "Taller Frame", "description": "+1.5 m launch height"},
	{"id": "aero", "name": "Sleek Shell", "description": "-20% air drag"},
	{"id": "bounce", "name": "Rubber Coat", "description": "+0.07 bounciness"},
	{"id": "boost", "name": "Rocket", "description": "+1 mid-air boost"},
	{"id": "heavy", "name": "Heavy Core", "description": "+30% launch speed, -0.1 bounciness"},
	{"id": "feather", "name": "Feather Shell", "description": "-40% air drag, -10% launch speed"},
	{"id": "steady", "name": "Steady Hand", "description": "Shows the line of your last shot"},
]
const MAX_RESTITUTION: float = 0.9
const MIN_RESTITUTION: float = 0.1


static func get_def(id: String) -> Dictionary:
	for p in LIST:
		if p["id"] == id:
			return p
	return {}


## A copy of `base` with every perk in `perk_ids` applied in order (the same perk can appear many times).
static func apply(base: PlayerStats, perk_ids: Array) -> PlayerStats:
	var s := PlayerStats.new()
	s.max_speed = base.max_speed
	s.launch_height = base.launch_height
	s.guide_points = base.guide_points
	s.drag = base.drag
	s.restitution = base.restitution
	s.boost_charges = base.boost_charges
	s.score_multiplier = base.score_multiplier
	s.star_value = base.star_value
	s.bounce_bonus = base.bounce_bonus
	for id in perk_ids:
		match id:
			"power":
				s.max_speed *= 1.15
			"height":
				s.launch_height += 1.5
			"aero":
				s.drag *= 0.8
			"bounce":
				s.restitution = minf(s.restitution + 0.07, MAX_RESTITUTION)
			"boost":
				s.boost_charges += 1
			"heavy":
				s.max_speed *= 1.3
				s.restitution = maxf(s.restitution - 0.1, MIN_RESTITUTION)
			"feather":
				s.drag *= 0.6
				s.max_speed *= 0.9
	return s


## `count` different perk ids, chosen with a RandomNumberGenerator seeded with `offer_seed`.
## "steady" is only offered until the player owns it.
static func offer(offer_seed: int, owned: Array, count: int = 3) -> Array[String]:
	var pool: Array[String] = []
	for p in LIST:
		if p["id"] == "steady" and owned.has("steady"):
			continue
		pool.append(p["id"])
	var rng := RandomNumberGenerator.new()
	rng.seed = offer_seed
	var out: Array[String] = []
	while out.size() < mini(count, pool.size()):
		var pick: String = pool[rng.randi_range(0, pool.size() - 1)]
		if not out.has(pick):
			out.append(pick)
	return out
