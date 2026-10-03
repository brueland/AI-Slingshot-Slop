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
## After the last of LIST a new milestone every MORE_EVERY meters for ever: its reward is its distance, and the
## names come round in turn.
const MORE_EVERY: float = 1000.0
const MORE_NAMES: Array[String] = ["Cloud Surfer", "Jet Setter", "Orbit Chaser", "Star Hopper", "Comet Rider", "Galaxy Glider"]

## Returns an array of milestone entries that were newly reached.
## Every entry in LIST with `previous_best < entry.distance` and `entry.distance <= distance`.
static func newly_reached(previous_best: float, distance: float) -> Array:
	var out := []
	for m in up_to(distance):
		if previous_best < m["distance"] and m["distance"] <= distance:
			out.append(m)
	return out

## Returns the first unreached milestone entry, or an empty dictionary if all are reached.
static func next_milestone(best: float) -> Dictionary:
	for m in LIST:
		if m["distance"] > best:
			return m
	return more(maxi(0, floori((best - float(LIST[LIST.size() - 1]["distance"])) / MORE_EVERY)))


## The k-th milestone after LIST (k = 0 is the first, 1000 m after the last of LIST).
static func more(k: int) -> Dictionary:
	var distance := float(LIST[LIST.size() - 1]["distance"]) + MORE_EVERY * (k + 1)
	return {"distance": distance, "reward": int(distance), "name": MORE_NAMES[k % MORE_NAMES.size()]}


## Every milestone up to `distance`: those of LIST, then the endless ones.
static func up_to(distance: float) -> Array:
	var out := []
	for m in LIST:
		if m["distance"] <= distance:
			out.append(m)
	var k := 0
	while more(k)["distance"] <= distance:
		out.append(more(k))
		k += 1
	return out
