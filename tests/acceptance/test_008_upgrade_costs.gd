extends GutTest
# Task 008: UpgradeCatalog.cost() and is_maxed() (docs/DESIGN.md section 4:
# cost of the next level when the current level is L = roundi(base_cost * pow(growth, L))).

const PATH := "res://scripts/core/upgrade_catalog.gd"


func _cat():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_known_costs() -> void:
	var cat = _cat()
	if cat == null:
		return
	assert_eq(cat.cost("power", 0), 80)
	assert_eq(cat.cost("power", 1), 136)
	assert_eq(cat.cost("power", 2), 231, "80 * 1.7^2 = 231.2 rounds to 231")
	assert_eq(cat.cost("guide", 0), 25)
	assert_eq(cat.cost("boosts", 2), 1452)
	assert_eq(cat.cost("multiplier", 4), 2606, "200 * 1.9^4 = 2606.42")
	assert_eq(cat.cost("aero", 3), 700, "120 * 1.8^3 = 699.84 rounds to 700")


func test_maxed_unknown_and_negative_levels_cost_minus_one() -> void:
	var cat = _cat()
	if cat == null:
		return
	assert_eq(cat.cost("boosts", 25), -1, "level 25 is the last (task 272)")
	assert_eq(cat.cost("power", 25), -1)
	assert_eq(cat.cost("power", -1), -1)
	assert_eq(cat.cost("laser", 0), -1)


func test_costs_follow_the_formula_and_increase() -> void:
	var cat = _cat()
	if cat == null:
		return
	for id in cat.ids():
		var d: Dictionary = cat.get_def(id)
		var previous := 0
		for level in int(d["max_level"]):
			var c: int = cat.cost(id, level)
			assert_eq(c, roundi(float(d["base_cost"]) * pow(float(d["growth"]), level)), "%s level %d" % [id, level])
			assert_gt(c, previous, "%s costs must rise" % id)
			previous = c


func test_is_maxed() -> void:
	var cat = _cat()
	if cat == null:
		return
	assert_true(cat.is_maxed("boosts", 25))
	assert_true(cat.is_maxed("boosts", 26))
	assert_false(cat.is_maxed("boosts", 3), "no longer maxed at 3")
	assert_false(cat.is_maxed("boosts", 2))
	assert_false(cat.is_maxed("power", 0))
