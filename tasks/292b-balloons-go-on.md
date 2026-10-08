---
id: 292b-balloons-go-on
status: ready
tests: [tests/acceptance/test_292b_balloons_go_on.gd]
files: [scripts/core/run_session.gd, scripts/core/balloons.gd]
---

# Balloons go on

When a long shot's course grows (task 291), the next 2000 m now get balloons as well: `Balloons.add_points` adds
them (hats rolled the way carry_hats rolls them) and `RunSession.extend_course()` lays them out from the next seed.
The views already follow (task 292).

**1. `scripts/core/run_session.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds four lines in `extend_course()` after `first_balloon`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	var first_balloon := balloons.points.size()
```
REPLACE:
```gdscript
	var first_balloon := balloons.points.size()
	var more: Array[Vector2] = []
	for p in Balloons.layout(chunk_seed, Balance.COURSE_LENGTH):
		more.append(p + Vector2(course_end, 0.0))
	balloons.add_points(more, chunk_seed)
```

**2. `scripts/core/balloons.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds `add_points()` between `carry_hats()` and `after_step()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
		hats.append(hat if rng.randi_range(1, 6) == 1 else "")


## Pops every balloon the alien touched between `previous_position` and its current position.
```
REPLACE:
```gdscript
		hats.append(hat if rng.randi_range(1, 6) == 1 else "")


## More balloons further along (the course grows during a long shot), with hats rolled from `hat_seed` the way
## carry_hats rolls them.
func add_points(more: Array[Vector2], hat_seed: int) -> void:
	var choices: Array[String] = ["cowboy", "viking", "beanie"]
	var rng := RandomNumberGenerator.new()
	rng.seed = hat_seed * 7919 + 17
	for p in more:
		points.append(p)
		used.append(false)
		var hat: String = choices[rng.randi_range(0, 2)]
		hats.append(hat if rng.randi_range(1, 6) == 1 else "")


## Pops every balloon the alien touched between `previous_position` and its current position.
```

## Acceptance criteria
- `extend_course()` adds the next COURSE_LENGTH meters of balloons (`Balloons.add_points`); they pop and show.
