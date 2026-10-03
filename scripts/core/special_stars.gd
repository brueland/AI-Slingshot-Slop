class_name SpecialStars
extends RefCounted
## Special stars: about one course in three has a purple star holding a special perk. Collecting it finds the perk
## for good: from then on it can turn up in roguelike perk offers (straight away in the run that found it).

const PERKS: Array = [
	{"id": "magnet", "name": "Star Magnet", "description": "+1.5 m star reach"},
	{"id": "super_ball", "name": "Super Ball", "description": "+0.15 bounciness"},
	{"id": "jet_pack", "name": "Jet Pack", "description": "+1 s of rocket"},
]
## The share of courses with a special star.
const CHANCE: float = 0.35


static func get_def(id: String) -> Dictionary:
	for p in PERKS:
		if p["id"] == id:
			return p
	return {}


static func is_perk(id: String) -> bool:
	return not get_def(id).is_empty()


## Marks the special star of a course, if it has one: one star item gets "special" (the id of the perk it holds).
static func mark(course: Array, course_seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = course_seed * 7717 + 3
	if rng.randf() >= CHANCE:
		return
	var stars := []
	for i in course.size():
		if course[i]["type"] == "star":
			stars.append(i)
	if stars.is_empty():
		return
	var pick: int = stars[rng.randi_range(0, stars.size() - 1)]
	course[pick]["special"] = str(PERKS[rng.randi_range(0, PERKS.size() - 1)]["id"])
