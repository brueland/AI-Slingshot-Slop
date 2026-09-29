extends GutTest
# Task 088: scripts/game/critters.gd, sheep grazing along the meadow. When the alien bounces within 4 m of a
# sheep, the sheep hops and a "Baa!" pops up.

const PATH := "res://scripts/game/critters.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_088_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _script():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_layout() -> void:
	var c = _script()
	if c == null:
		return
	var consts: Dictionary = c.get_script_constant_map()
	assert_eq(consts.get("SEED"), 11)
	assert_almost_eq(float(consts.get("REACT_DISTANCE", 0.0)), 4.0, 0.0001)
	assert_almost_eq(float(consts.get("HOP_SECONDS", 0.0)), 0.5, 0.0001)
	var xs: Array = c.layout(11, 2000.0)
	assert_eq(xs, c.layout(11, 2000.0), "same seed, same flock")
	assert_gt(xs.size(), 15)
	var previous := 25.0
	for x in xs:
		assert_between(x - previous, 35.0, 90.0, "one sheep every 35-90 m")
		previous = x
	assert_lt(previous, 2000.0)


func test_react_and_hop() -> void:
	var c = _script()
	if c == null:
		return
	var sheep = c.new()
	add_child_autofree(sheep)
	sheep.build(11, 2000.0)
	var x0: float = sheep.xs[0]
	assert_eq(sheep.react(x0 + 10.0), -1, "too far away")
	assert_eq(sheep.react(x0 - 3.5), 0, "close enough")
	assert_eq(sheep.hop_offset(0), 0.0, "the hop starts on the ground")
	sheep.advance(0.25)
	assert_almost_eq(sheep.hop_offset(0), 14.0, 0.01, "highest halfway")
	var feet: Vector2 = sheep.sheep_position(0)
	assert_almost_eq(feet.y, WorldView.world_to_screen(Vector2(x0, 0.0)).y - 14.0, 0.01)
	sheep.advance(0.3)
	assert_eq(sheep.hop_offset(0), 0.0, "back on the ground")
	await wait_process_frames(2)
	pass_test("the flock draws without errors")


func test_main_has_sheep_that_baa() -> void:
	if _script() == null:
		return
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var sheep = main.get("critters")
	assert_not_null(sheep, "main.critters")
	if sheep == null:
		return
	assert_eq(sheep.xs, _script().layout(11, 2000.0))
	assert_gt(sheep.get_index(), main.scenery.get_index(), "in front of the bushes")
	assert_lt(sheep.get_index(), main.course_view.get_index(), "behind the course items")
	assert_eq(main.feedback.critters, sheep)
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	main.session.sim.position = Vector2(sheep.xs[0] + 1.0, 0.0)
	main.session.sim.bounced.emit(6.0)
	assert_gt(sheep.hop_left[0], 0.0, "the sheep hops")
	var texts := []
	for p in main.popups.get_children():
		texts.append(p.text)
	assert_true(texts.has("Baa!"), "popups: %s" % [texts])
