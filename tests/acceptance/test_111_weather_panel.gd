extends GutTest
# Task 111: the roguelike perk panel shows the weather of the round about to be played, under the next goal.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_111_save.json"
const WEATHER := "res://scripts/core/rogue_weather.gd"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_panel_shows_the_weather() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_rogue(42)
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	var panel = main.ui_layer.rogue_panel
	assert_true(panel.get("weather_label") is Label, "rogue_panel.weather_label")
	if not panel.get("weather_label") is Label:
		return
	assert_eq(panel.weather_label.text, "Weather: Calm - no change", "round 2 is calm")
	main.rogue.weather = "tailwind"
	panel.show_outcome(main.rogue_outcome, main.rogue)
	assert_eq(panel.weather_label.text, "Weather: Tailwind - +8% launch speed")
	main.rogue.weather = "soggy"
	panel.show_outcome(main.rogue_outcome, main.rogue)
	assert_eq(panel.weather_label.text, "Weather: Soggy Ground - -0.1 bounciness")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "the panel still fits on screen")
