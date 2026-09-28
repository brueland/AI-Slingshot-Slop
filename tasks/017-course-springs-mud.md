---
id: 017-course-springs-mud
status: ready
tests: [tests/acceptance/test_017_course_springs_mud.gd]
files: [scripts/core/course_generator.gd]
---

# Course generator part 2: springs and mud

Edit `scripts/core/course_generator.gd`. After the star loop (same `rng`, before sorting), add springs and
then mud patches, both on the ground (`"y": 0.0`):

- **Springs**: start `x = 40.0`; repeat `x += rng.randf_range(60.0, 120.0)`; stop when `x >= length`;
  append `{"type": "spring", "x": x, "y": 0.0}`.
- **Mud**: start `x = 50.0`; repeat `x += rng.randf_range(80.0, 150.0)`; stop when `x >= length`;
  append `{"type": "mud", "x": x, "y": 0.0}`.

A small helper keeps it short:

```gdscript
static func _add_ground_items(items: Array, rng: RandomNumberGenerator, type: String, start: float,
		gap_min: float, gap_max: float, length: float) -> void:
	var x := start
	while true:
		x += rng.randf_range(gap_min, gap_max)
		if x >= length:
			break
		items.append({"type": type, "x": x, "y": 0.0})
```

Call it for springs (40, 60, 120), then mud (50, 80, 150). The final `sort_custom` by x stays at the end.

## Acceptance criteria
- Springs: first at 100-160 m, then every 60-120 m. Mud: first at 130-200 m, then every 80-150 m.
- The whole list is sorted by x and only has types star, spring, mud; still deterministic per seed.
