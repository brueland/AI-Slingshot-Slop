class_name CourseGenerator
extends RefCounted
## Deterministic course items from a seed. See docs/DESIGN.md section 6.


static func _add_ground_items(items: Array, rng: RandomNumberGenerator, type: String, start: float,
		gap_min: float, gap_max: float, length: float) -> void:
	var x := start
	while true:
		x += rng.randf_range(gap_min, gap_max)
		if x >= length:
			break
		items.append({"type": type, "x": x, "y": 0.0})


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
	_add_ground_items(items, rng, "spring", 40.0, 60.0, 120.0, length)
	_add_ground_items(items, rng, "mud", 50.0, 80.0, 150.0, length)
	items.sort_custom(func(a, b): return a["x"] < b["x"])
	return items
