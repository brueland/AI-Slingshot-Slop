extends GutTest
# Task 001: scripts/core/balance.gd holds every tuning constant (docs/DESIGN.md section 3).

const PATH := "res://scripts/core/balance.gd"

const EXPECTED_FLOATS := {
	"GRAVITY": 15.0, "BASE_MAX_SPEED": 22.0, "MAX_PULL_PX": 120.0, "MIN_PULL_PX": 10.0,
	"BASE_LAUNCH_HEIGHT": 2.0, "BASE_DRAG": 0.002, "BASE_RESTITUTION": 0.35, "BOUNCE_FRICTION": 0.85,
	"MIN_BOUNCE_SPEED": 2.0, "SLIDE_FRICTION": 6.0, "STOP_SPEED": 0.1, "BOOST_SPEED": 12.0,
	"STAR_RADIUS": 1.5, "SPRING_SPEED": 14.0, "SPRING_PUSH": 4.0, "SPRING_HALF_WIDTH": 1.5,
	"MUD_FACTOR": 0.5, "MUD_WIDTH": 6.0, "COURSE_LENGTH": 2000.0, "GOAL_DISTANCE": 1000.0,
	"MAX_RUN_SECONDS": 120.0, "PIXELS_PER_METER": 16.0, "PROJECTILE_RADIUS": 0.75,
}
const EXPECTED_INTS := {"BASE_GUIDE_POINTS": 6, "BASE_STAR_VALUE": 10}


func _constants() -> Dictionary:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return {}
	return load(PATH).get_script_constant_map()


func test_float_constants() -> void:
	var consts := _constants()
	if consts.is_empty():
		return
	for key in EXPECTED_FLOATS:
		assert_true(consts.has(key), "Balance.%s is missing" % key)
		if consts.has(key):
			assert_eq(typeof(consts[key]), TYPE_FLOAT, "Balance.%s must be a float" % key)
			assert_almost_eq(float(consts[key]), float(EXPECTED_FLOATS[key]), 0.000001, "Balance.%s" % key)


func test_int_constants() -> void:
	var consts := _constants()
	if consts.is_empty():
		return
	for key in EXPECTED_INTS:
		assert_true(consts.has(key), "Balance.%s is missing" % key)
		if consts.has(key):
			assert_eq(typeof(consts[key]), TYPE_INT, "Balance.%s must be an int" % key)
			assert_eq(consts[key], EXPECTED_INTS[key], "Balance.%s" % key)


func test_declares_class_name() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var text := FileAccess.get_file_as_string(PATH)
	assert_true(text.contains("class_name Balance"), "balance.gd must declare 'class_name Balance'")
	assert_true(text.contains("extends RefCounted"), "balance.gd must extend RefCounted")
