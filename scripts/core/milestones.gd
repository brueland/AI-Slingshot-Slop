class_name Milestones
extends RefCounted
## One-time distance rewards. See docs/DESIGN.md section 5.

const LIST: Array = [
	{"distance": 50.0, "reward": 25, "name": "First Flight"},
	{"distance": 100.0, "reward": 50, "name": "Century"},
	{"distance": 250.0, "reward": 150, "name": "Sky Sprinter"},
	{"distance": 500.0, "reward": 300, "name": "Half-K Hero"},
	{"distance": 1000.0, "reward": 1000, "name": "Moon Shot"},
]

## Returns an array of milestone entries that were newly reached.
## Every entry in LIST with `previous_best < entry.distance` and `entry.distance <= distance`.
static func newly_reached(previous_best: float, distance: float) -> Array:
	var out := []
	for m in LIST:
		if previous_best < m["distance"] and m["distance"] <= distance:
			out.append(m)
	return out

## Returns the first unreached milestone entry, or an empty dictionary if all are reached.
static func next_milestone(best: float) -> Dictionary:
	for m in LIST:
		if m["distance"] > best:
			return m
	return {}
