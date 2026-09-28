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
