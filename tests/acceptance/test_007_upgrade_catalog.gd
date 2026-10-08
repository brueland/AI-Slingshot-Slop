extends GutTest
# Task 007: scripts/core/upgrade_catalog.gd, the table of 9 upgrades and lookups
# (docs/DESIGN.md sections 4 and 9).

const PATH := "res://scripts/core/upgrade_catalog.gd"

const ORDER := ["power", "height", "guide", "aero", "bounce", "boosts", "multiplier", "star_value", "bounce_bonus"]

# id: [name, category, max_level, base_cost, growth, per_level]
const TABLE := {
	"power": ["Band Power", "launcher", 25, 80, 1.7, 0.25],
	"height": ["Tall Frame", "launcher", 25, 60, 1.7, 1.5],
	"guide": ["Aim Guide", "launcher", 12, 25, 1.5, 6],
	"aero": ["Aerodynamics", "projectile", 25, 120, 1.8, 0.18],
	"bounce": ["Bouncy Shell", "projectile", 8, 100, 1.8, 0.08],
	"boosts": ["Rocket Boosts", "projectile", 25, 300, 2.2, 1],
	"multiplier": ["Score Multiplier", "score", 25, 200, 1.9, 0.25],
	"star_value": ["Star Polish", "score", 25, 80, 1.7, 5],
	"bounce_bonus": ["Style Points", "score", 25, 60, 1.7, 3],
}


func _cat():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_ids_in_order() -> void:
	var cat = _cat()
	if cat == null:
		return
	var ids: Array = cat.ids()
	assert_eq(ids.size(), 9)
	for i in ORDER.size():
		if i < ids.size():
			assert_eq(ids[i], ORDER[i], "ids()[%d]" % i)


func test_every_definition_matches_the_design_table() -> void:
	var cat = _cat()
	if cat == null:
		return
	for id in TABLE:
		var d: Dictionary = cat.get_def(id)
		var want: Array = TABLE[id]
		for key in ["name", "category", "max_level", "base_cost", "growth", "per_level", "description"]:
			assert_true(d.has(key), "%s is missing '%s'" % [id, key])
		if d.size() < 7:
			continue
		assert_eq(d["name"], want[0], id + " name")
		assert_eq(d["category"], want[1], id + " category")
		assert_eq(int(d["max_level"]), want[2], id + " max_level")
		assert_eq(int(d["base_cost"]), want[3], id + " base_cost")
		assert_almost_eq(float(d["growth"]), float(want[4]), 0.0001, id + " growth")
		assert_almost_eq(float(d["per_level"]), float(want[5]), 0.0001, id + " per_level")
		assert_true(str(d["description"]).length() > 0, id + " needs a description")


func test_categories() -> void:
	var cat = _cat()
	if cat == null:
		return
	assert_eq(cat.CATEGORIES, ["launcher", "projectile", "score"])
	assert_eq(cat.CATEGORY_NAMES.get("launcher"), "Slingshot")
	assert_eq(cat.CATEGORY_NAMES.get("projectile"), "Projectile")
	assert_eq(cat.CATEGORY_NAMES.get("score"), "Score")
	assert_eq(cat.ids_in_category("launcher"), ["power", "height", "guide"])
	assert_eq(cat.ids_in_category("projectile"), ["aero", "bounce", "boosts"])
	assert_eq(cat.ids_in_category("score"), ["multiplier", "star_value", "bounce_bonus"])
	assert_eq(cat.ids_in_category("nope"), [])


func test_lookups_for_unknown_ids() -> void:
	var cat = _cat()
	if cat == null:
		return
	assert_true(cat.is_valid("power"))
	assert_false(cat.is_valid("laser"))
	assert_eq(cat.get_def("laser"), {})
	assert_eq(cat.max_level("laser"), 0)
	assert_eq(cat.max_level("boosts"), 25, "no real cap since task 272")
