extends GutTest
# Task 055: scripts/game/ground_shadow.gd draws a soft shadow on the ground under the projectile, smaller and
# fainter the higher it flies; main.gd keeps it under the projectile while aiming and flying.

const PATH := "res://scripts/game/ground_shadow.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_055_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_shadow_follows_on_the_ground() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var s = load(PATH).new()
	add_child_autofree(s)
	assert_true(s is Node2D)
	s.update_from(Vector2(10, 0))
	assert_eq(s.position, Vector2(160, 0), "always on the ground (screen y = 0)")
	assert_almost_eq(s.shadow_scale, 1.0, 0.0001)
	s.update_from(Vector2(10, 15))
	assert_eq(s.position, Vector2(160, 0))
	assert_almost_eq(s.shadow_scale, 0.5, 0.0001, "1 - height / 30")
	s.update_from(Vector2(20, 100))
	assert_almost_eq(s.shadow_scale, 0.3, 0.0001, "never smaller than 0.3")
	await wait_process_frames(2)


func test_main_keeps_the_shadow_under_the_projectile() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var shadow = main.get("shadow")
	assert_not_null(shadow, "main.shadow")
	if shadow == null:
		return
	assert_lt(shadow.get_index(), main.projectile_view.get_index(), "drawn behind the projectile")
	main.start_game()
	assert_almost_eq(shadow.position.x, 0.0, 0.001, "under the waiting projectile")
	main.launch_with_pull(FULL_PULL_45)
	for i in 40:
		main.advance(1.0 / 60.0)
	var sim = main.session.sim
	assert_almost_eq(shadow.position.x, sim.position.x * 16.0, 0.01)
	assert_almost_eq(shadow.position.y, 0.0, 0.001)
	assert_almost_eq(shadow.shadow_scale, clampf(1.0 - sim.position.y / 30.0, 0.3, 1.0), 0.0001)
