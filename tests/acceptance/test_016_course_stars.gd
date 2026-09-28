extends GutTest
# Task 016: scripts/core/course_generator.gd places stars deterministically from a seed
# (docs/DESIGN.md section 6). Later tasks add springs and mud to the same list, so this test only
# looks at items whose type is "star".

const PATH := "res://scripts/core/course_generator.gd"


func _gen():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func _stars(items: Array) -> Array:
	return items.filter(func(it): return it.get("type") == "star")


func test_items_have_type_x_y() -> void:
	var gen = _gen()
	if gen == null:
		return
	var items: Array = gen.generate(7, 500.0)
	assert_gt(items.size(), 0)
	for it in items:
		assert_true(it is Dictionary and it.has("type") and it.has("x") and it.has("y"), "item: %s" % str(it))


func test_same_seed_same_course_different_seed_different_course() -> void:
	var gen = _gen()
	if gen == null:
		return
	assert_eq(gen.generate(42, 2000.0), gen.generate(42, 2000.0))
	assert_ne(_stars(gen.generate(1, 2000.0)), _stars(gen.generate(2, 2000.0)))


func test_star_spacing_and_heights() -> void:
	var gen = _gen()
	if gen == null:
		return
	for seed in [1, 2, 3, 99]:
		var stars := _stars(gen.generate(seed, 2000.0))
		assert_between(stars.size(), 60, 170, "about one star every 21 m")
		if stars.is_empty():
			continue
		assert_between(float(stars[0]["x"]), 32.0, 50.0, "the first star is 20 + 12..30 m out")
		for i in stars.size():
			var s: Dictionary = stars[i]
			assert_between(float(s["y"]), 1.5, 10.0, "star height")
			assert_lt(float(s["x"]), 2000.0, "inside the course")
			if i > 0:
				var gap := float(s["x"]) - float(stars[i - 1]["x"])
				assert_between(gap, 12.0, 30.0, "gap between stars %d and %d" % [i - 1, i])


func test_short_course_has_no_stars() -> void:
	var gen = _gen()
	if gen == null:
		return
	assert_eq(_stars(gen.generate(5, 30.0)), [], "the first star is at least 32 m out")
