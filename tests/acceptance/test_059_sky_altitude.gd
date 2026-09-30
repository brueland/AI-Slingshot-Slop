extends GutTest
# Task 059 (updated by task 211): as the projectile climbs, the sky darkens toward space (SkyBackground.set_altitude
# sets the SkyGradient's height) and the clouds fade out; the clouds drift slowly on their own (Parallax2D autoscroll).

const PATH := "res://scripts/game/background.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_059_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_set_altitude_darkens_the_sky() -> void:
	var bg = load(PATH).new()
	add_child_autofree(bg)
	bg.set_altitude(0.0)
	assert_eq(bg.sky_gradient.height, 0.0)
	assert_eq(bg.layers[1].modulate.a, 1.0, "clouds near the ground")
	bg.set_altitude(90.0)
	assert_eq(bg.sky_gradient.height, 90.0)
	assert_almost_eq(bg.layers[1].modulate.a, 0.5, 0.0001, "the clouds are half gone at 90 m")
	bg.set_altitude(1000.0)
	assert_eq(bg.layers[1].modulate.a, 0.0, "no clouds up in space")
	assert_eq(bg.modulate, Color.WHITE, "nothing is tinted")


func test_clouds_drift() -> void:
	var bg = load(PATH).new()
	add_child_autofree(bg)
	assert_eq(bg.layers[1].autoscroll, Vector2(-12, 0), "clouds drift left at 12 px/s")
	assert_eq(bg.layers[0].autoscroll, Vector2.ZERO, "the sky itself doesn't move")


func test_main_follows_the_flight_height() -> void:
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
	assert_almost_eq(main.background.sky_gradient.height, h, 0.0001, "the sky follows the height")
	for i in 30000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.continue_to_shop()
	main.leave_shop()
	assert_eq(main.background.sky_gradient.height, 0.0, "back to the ground sky for the next shot")
