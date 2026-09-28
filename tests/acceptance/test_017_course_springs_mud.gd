extends GutTest
# Task 017: CourseGenerator also places springs and mud, and returns all items sorted by x
# (docs/DESIGN.md section 6).

const PATH := "res://scripts/core/course_generator.gd"


func _gen():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func _of(items: Array, type: String) -> Array:
	return items.filter(func(it): return it.get("type") == type)


func _check_spacing(list: Array, first_min: float, first_max: float, gap_min: float, gap_max: float, what: String) -> void:
	assert_gt(list.size(), 0, "a 2000 m course has " + what)
	if list.is_empty():
		return
	assert_between(float(list[0]["x"]), first_min, first_max, "first " + what)
	for i in list.size():
		assert_almost_eq(float(list[i]["y"]), 0.0, 0.0001, what + " sit on the ground")
		assert_lt(float(list[i]["x"]), 2000.0)
		if i > 0:
			assert_between(float(list[i]["x"]) - float(list[i - 1]["x"]), gap_min, gap_max, what + " gap")


func test_springs() -> void:
	var gen = _gen()
	if gen == null:
		return
	for seed in [1, 2, 3]:
		_check_spacing(_of(gen.generate(seed, 2000.0), "spring"), 100.0, 160.0, 60.0, 120.0, "springs")


func test_mud() -> void:
	var gen = _gen()
	if gen == null:
		return
	for seed in [1, 2, 3]:
		_check_spacing(_of(gen.generate(seed, 2000.0), "mud"), 130.0, 200.0, 80.0, 150.0, "mud")


func test_sorted_and_only_known_types() -> void:
	var gen = _gen()
	if gen == null:
		return
	var items: Array = gen.generate(11, 2000.0)
	for i in items.size():
		assert_true(items[i]["type"] in ["star", "spring", "mud"])
		if i > 0:
			assert_true(float(items[i]["x"]) >= float(items[i - 1]["x"]), "sorted by x at %d" % i)


func test_still_deterministic() -> void:
	var gen = _gen()
	if gen == null:
		return
	assert_eq(gen.generate(8, 2000.0), gen.generate(8, 2000.0))
