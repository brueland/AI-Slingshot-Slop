extends GutTest
# Task 128: scripts/game/weather_fx.gd shows the roguelike weather on screen (wind streaks, rain, sparkles, haze);
# calm and classic shots show nothing.

const PATH := "res://scripts/game/weather_fx.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_128_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_weather_fx() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var w = load(PATH)
	var fx = w.new()
	add_child_autofree(fx)
	assert_true(fx is CanvasLayer)
	assert_eq(fx.weather, "calm")
	assert_false(fx.canvas.visible, "calm shows nothing")
	for id in ["tailwind", "headwind", "thick_air", "springy", "soggy"]:
		fx.show_weather(id)
		assert_eq(fx.weather, id)
		assert_true(fx.canvas.visible)
		await wait_process_frames(2)
	fx.show_weather("snow")
	assert_eq(fx.weather, "calm", "unknown weather is calm")
	assert_false(fx.canvas.visible)
	var size := Vector2(1280, 720)
	for i in 10:
		var p: Vector2 = w.particle_position(i, 12.3, size, w.velocity_for("tailwind"))
		assert_true(Rect2(Vector2.ZERO, size).has_point(p), "particles wrap around the screen")
	assert_eq(w.velocity_for("calm"), Vector2.ZERO)
	assert_gt(w.velocity_for("tailwind").x, 0.0, "a tailwind blows forward")
	assert_lt(w.velocity_for("headwind").x, 0.0)


func test_main_shows_the_weather() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	assert_not_null(main.get("weather_fx"), "main.weather_fx")
	if main.get("weather_fx") == null:
		return
	assert_lt(main.weather_fx.get_index(), main.ui_layer.get_index(), "under the UI")
	main.start_game()
	assert_eq(main.weather_fx.weather, "calm", "classic has no weather")
	main.go_to_title()
	main.start_rogue(7)
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.rogue.weather = "soggy"
	main.choose_rogue_perk(main.rogue.offer[0])
	assert_eq(main.weather_fx.weather, "soggy", "the round's weather is on screen")
