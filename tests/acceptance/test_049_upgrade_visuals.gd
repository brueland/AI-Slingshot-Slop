extends GutTest
# Task 049: upgrades are visible. Slingshot.apply_stats() sets the frame height and a band color per Band
# Power tier; main.gd also picks the projectile texture tier from the Aerodynamics level.

const SLING := "res://scripts/game/slingshot.gd"
const STATS := "res://scripts/core/player_stats.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_049_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_slingshot_apply_stats() -> void:
	var sling_script = load(SLING)
	var colors: Array = sling_script.BAND_COLORS
	assert_eq(colors.size(), 3)
	assert_eq(colors[0], Color(0.35, 0.2, 0.1))
	assert_eq(colors[1], Color(0.8, 0.2, 0.2))
	assert_eq(colors[2], Color(1.0, 0.8, 0.2))
	var s = sling_script.new()
	add_child_autofree(s)
	s.apply_stats(load(STATS).from_levels({"height": 2}), 5)
	assert_almost_eq(s.frame_height_px, 80.0, 0.001, "(2 + 1.5 * 2) m * 16 px")
	assert_eq(s.band_color, colors[1], "power 4-7 is tier 1")
	s.apply_stats(load(STATS).from_levels({}), 0)
	assert_eq(s.band_color, colors[0])
	assert_almost_eq(s.frame_height_px, 32.0, 0.001)
	s.apply_stats(load(STATS).from_levels({}), 10)
	assert_eq(s.band_color, colors[2], "power 8-10 is tier 2")


func test_main_shows_upgrades() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.progress.levels = {"aero": 4, "power": 8, "height": 1}
	main.start_game()
	assert_eq(main.projectile_view.tier, 2, "aero 4 -> tier 2 (aero / 2)")
	assert_eq(main.slingshot.band_color, load(SLING).BAND_COLORS[2])
	assert_almost_eq(main.slingshot.frame_height_px, 56.0, 0.001)
	main.progress.levels = {"aero": 3}
	main.go_to_title()
	main.start_game()
	assert_eq(main.projectile_view.tier, 1, "aero 3 -> tier 1")
