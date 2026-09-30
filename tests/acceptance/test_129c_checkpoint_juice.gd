extends GutTest
# Checkpoint 14 (task 129c): the milestone 14 features work together with real frames: a keyboard-aimed shot with
# fading aim dots and twinkling stars, a spring's "Boing!", and the roguelike weather on screen.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_129c_save.json"


func before_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func after_each() -> void:
	before_each()


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func _key(code: int) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.pressed = true
	return e


func test_keyboard_shot_with_real_frames() -> void:
	var main = _main()
	main.start_game()
	await wait_process_frames(2)
	for i in 4:
		main.slingshot._unhandled_input(_key(KEY_RIGHT))
	await wait_process_frames(2)
	assert_gt(main.trajectory.points.size(), 1, "the aim preview shows")
	var star_scale: Vector2 = main.course_view.sprites[main.course_view.star_indices[0]].scale
	await wait_seconds(0.3)
	assert_ne(main.course_view.sprites[main.course_view.star_indices[0]].scale, star_scale, "stars twinkle")
	var expected: Vector2 = main.slingshot.key_pull()
	main.slingshot._unhandled_input(_key(KEY_ENTER))
	assert_eq(main.state_name(), "FLIGHT")
	assert_eq(main.slingshot.last_pull, expected, "launched with the keyboard aim")
	main.session.tracker.spring_hit.emit(0)
	var texts := []
	for c in main.popups.get_children():
		texts.append(c.text)
	assert_true(texts.has("Boing!"))


func test_weather_on_screen_with_real_frames() -> void:
	var main = _main()
	main.start_rogue(11)
	main.rogue.round_number = 3
	main.rogue.weather = "tailwind"
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.rogue.weather = "tailwind"
	main.ui_layer.rogue_panel.perk_buttons[0].pressed.emit()
	await wait_process_frames(3)
	assert_eq(main.weather_fx.weather, "tailwind")
	assert_true(main.weather_fx.canvas.visible)
	assert_gt(main.weather_fx.time, 0.0, "the wind blows with real frames")


func test_new_scripts_follow_the_conventions() -> void:
	var scripts := {"res://scripts/game/world_builder.gd": "WorldBuilder", "res://scripts/game/weather_fx.gd": "WeatherFx"}
	for path in scripts:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + scripts[path]))
		assert_lt(text.split("
").size(), 300)
		assert_false(text.contains("print("))
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("
").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_14() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 14: complete"), "add the line 'Milestone 14: complete' to docs/PROGRESS.md")
