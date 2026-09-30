extends GutTest
# Task 116: scripts/game/ufo.gd, friendly UFOs hovering 22 m up at 180, 420, 750, 1100 and 1600 m. When the alien flies
# within 220 px of one it turns its beam on and says hello (once per shot); a new shot resets them.

const PATH := "res://scripts/game/ufo.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_116_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _script():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_greetings() -> void:
	var u = _script()
	if u == null:
		return
	assert_eq(u.SPOTS_M, [180.0, 420.0, 750.0, 1100.0, 1600.0])
	var ufo = u.new()
	add_child_autofree(ufo)
	assert_eq(ufo.greeted, [false, false, false, false, false])
	var base: Vector2 = WorldView.world_to_screen(Vector2(420.0, 22.0))
	assert_lt(ufo.ufo_position(1).distance_to(base), 21.0, "hovers near its spot")
	assert_eq(ufo.greet_near(base + Vector2(0, 400)), 0, "too far away")
	assert_eq(ufo.greet_near(base + Vector2(0, 150)), 1)
	assert_true(ufo.greeted[1])
	assert_eq(ufo.greet_near(base), 0, "says hello once per shot")
	var hellos := []
	for c in ufo.get_children():
		if c is FloatingText:
			hellos.append(c.text)
	assert_eq(hellos, ["Nice flight!"])
	ufo.reset()
	assert_false(ufo.greeted[1])
	ufo.greet_near(base)
	ufo.advance(0.5)
	await wait_process_frames(2)
	pass_test("UFOs (and their beams) draw without errors")


func test_ufos_in_the_game() -> void:
	if _script() == null:
		return
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var ufo = main.get("ufo")
	assert_not_null(ufo, "main.ufo")
	if ufo == null:
		return
	assert_eq(ufo.target, main.projectile_view)
	main.start_game()
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	main.advance(1.0 / 60.0)
	main.toggle_pause()
	main.projectile_view.position = ufo.ufo_position(0) + Vector2(0, 100)
	await wait_process_frames(2)
	assert_true(ufo.greeted[0], "the alien flew close, so the UFO said hello")
	main.toggle_pause()
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.continue_to_shop()
	main.leave_shop()
	assert_false(ufo.greeted[0], "a new shot resets the UFOs")
