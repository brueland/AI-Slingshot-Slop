extends GutTest
# Task 059: the sky deepens toward dark blue as the projectile climbs (SkyBackground.set_altitude), and the
# clouds drift slowly on their own (Parallax2D autoscroll).

const PATH := "res://scripts/game/background.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_059_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)
const HIGH := Color(0.45, 0.5, 0.85)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_set_altitude_tints_the_sky() -> void:
	var bg = load(PATH).new()
	add_child_autofree(bg)
	bg.set_altitude(0.0)
	assert_eq(bg.modulate, Color.WHITE, "normal colors on the ground")
	bg.set_altitude(75.0)
	assert_true(bg.modulate.is_equal_approx(Color.WHITE.lerp(HIGH, 0.5)), "halfway at 75 m, got %s" % bg.modulate)
	bg.set_altitude(1000.0)
	assert_true(bg.modulate.is_equal_approx(HIGH), "full tint from 150 m up")
	bg.set_altitude(-5.0)
	assert_eq(bg.modulate, Color.WHITE)


func test_clouds_drift() -> void:
	var bg = load(PATH).new()
	add_child_autofree(bg)
	assert_eq(bg.layers[1].autoscroll, Vector2(-12, 0), "clouds drift left at 12 px/s")
	assert_eq(bg.layers[0].autoscroll, Vector2.ZERO, "the sky itself doesn't move")


func test_main_tints_by_flight_height() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.progress.levels = {"power": 6}
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 60:
		main.advance(1.0 / 60.0)
	var h: float = main.session.sim.position.y
	assert_gt(h, 5.0)
	assert_true(main.background.modulate.is_equal_approx(Color.WHITE.lerp(HIGH, clampf(h / 150.0, 0.0, 1.0))),
		"sky tint follows the height (%.1f m)" % h)
	for i in 30000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.continue_to_shop()
	main.leave_shop()
	assert_eq(main.background.modulate, Color.WHITE, "back to normal for the next shot")
