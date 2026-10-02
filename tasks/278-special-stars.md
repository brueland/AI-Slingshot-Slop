---
id: 278-special-stars
status: ready
tests: [tests/acceptance/test_278_special_stars.gd, tests/acceptance/test_079_rogue_flow.gd]
files: [scripts/core/special_stars.gd, scripts/core/run_tracker.gd, scripts/core/run_session.gd]
---

# Special stars

About one course in three gets a special star: `SpecialStars.mark` (a new core script) gives one of its stars a
`special` perk id (Star Magnet, Super Ball or Jet Pack). Collecting it finds the perk (`RunTracker.found_specials`)
and the shot's result lists it under "found", so it is kept (task 275). Task 279 makes found perks show up in
roguelike perk offers. Older test 079 now expects the next course with its special star (the course of
`RunSession.new(rogue.stats(), 7002)`).

**1. Create the file `scripts/core/special_stars.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
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
```

**2. `scripts/core/run_tracker.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 2 adds two lines after `stars_collected += 1` in the star case; nothing else changes.

Edit 1 - SEARCH:
```gdscript
var mud_hits: int = 0
```
REPLACE:
```gdscript
var mud_hits: int = 0
## The special perks of the special stars collected this shot (see SpecialStars).
var found_specials: Array[String] = []
```

Edit 2 - SEARCH:
```gdscript
					stars_collected += 1
```
REPLACE:
```gdscript
					stars_collected += 1
					if item.has("special"):
						found_specials.append(str(item["special"]))
```

**3. `scripts/core/run_session.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	course = CourseGenerator.generate(course_seed, Balance.COURSE_LENGTH)
```
REPLACE:
```gdscript
	course = CourseGenerator.generate(course_seed, Balance.COURSE_LENGTH)
	SpecialStars.mark(course, course_seed)
```

Edit 2 - SEARCH:
```gdscript
	r["found"] = balloons.found_hats.duplicate()
```
REPLACE:
```gdscript
	r["found"] = balloons.found_hats.duplicate()
	r["found"].append_array(tracker.found_specials)
```

## Acceptance criteria
- `SpecialStars.mark(course, seed)` marks at most one star (about one course in three).
- Collecting it adds its perk to `found_specials`; `result()["found"]` includes them.
