extends GutTest
# Task 047: CameraRig can shake (a fading random offset); main.gd shakes it when a spring fires and on hard
# bounces.

const PATH := "res://scripts/game/camera_rig.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_047_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _cam():
	var c = load(PATH).new()
	add_child_autofree(c)
	return c


func test_shake_fades_out() -> void:
	var c = _cam()
	assert_false(c.is_shaking())
	c.shake(10.0, 0.5)
	assert_true(c.is_shaking())
	c.update_shake(0.1)
	assert_ne(c.offset, Vector2.ZERO, "shaking moves the offset")
	assert_true(absf(c.offset.x) <= 8.0 and absf(c.offset.y) <= 8.0, "strength fades: 10 * 0.4 / 0.5 = 8")
	c.update_shake(1.0)
	assert_false(c.is_shaking())
	assert_eq(c.offset, Vector2.ZERO, "the offset returns to zero")


func test_shake_is_deterministic() -> void:
	var a = _cam()
	var b = _cam()
	a.shake(6.0, 0.3)
	b.shake(6.0, 0.3)
	for i in 5:
		a.update_shake(0.02)
		b.update_shake(0.02)
		assert_eq(a.offset, b.offset, "same seed, same shake")


func test_follow_still_works_while_shaking() -> void:
	var c = _cam()
	c.snap_to(Vector2(0, 0))
	c.shake(10.0, 0.5)
	c.update_shake(0.1)
	assert_eq(c.position, Vector2(320, -260), "shake uses offset, not position")


func test_main_shakes_on_springs_and_hard_bounces() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.session.sim.bounced.emit(3.0)
	assert_false(main.camera.is_shaking(), "soft bounces don't shake")
	main.session.sim.bounced.emit(9.0)
	assert_true(main.camera.is_shaking(), "bounces of 8 m/s or more shake")
	main.camera.update_shake(10.0)
	main.session.tracker.spring_hit.emit(0)
	assert_true(main.camera.is_shaking(), "springs shake")
	assert_almost_eq(main.camera.shake_strength, 10.0, 0.001)
