---
id: 016-course-stars
status: ready
tests: [tests/acceptance/test_016_course_stars.gd]
files: [scripts/core/course_generator.gd]
---

# Course generator part 1: stars

Create `scripts/core/course_generator.gd`. It builds the list of course items from a seed, so the same seed
always gives the same course.

```gdscript
class_name CourseGenerator
extends RefCounted
## Deterministic course items from a seed. See docs/DESIGN.md section 6.


static func generate(seed: int, length: float) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var items: Array = []
	var x := 20.0
	while true:
		x += rng.randf_range(12.0, 30.0)
		if x >= length:
			break
		items.append({"type": "star", "x": x, "y": rng.randf_range(1.5, 10.0)})
	items.sort_custom(func(a, b): return a["x"] < b["x"])
	return items
```

Each item is a Dictionary `{"type": String, "x": float, "y": float}` (meters). Task 017 adds springs and mud
to the same list using the same `rng` after the stars, so keep the star loop first.

## Acceptance criteria
- Same seed -> identical list; different seeds -> different stars.
- Stars start 32-50 m out, are 12-30 m apart, 1.5-10 m high, and all inside `length`.
