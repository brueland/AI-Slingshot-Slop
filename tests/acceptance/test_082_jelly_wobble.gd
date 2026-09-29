extends GutTest
# Task 082: the alien wobbles like jelly after a bounce (squash and stretch for 0.4 s), then is round again.

const PATH := "res://scripts/game/projectile_view.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_082_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _view():
	var v = load(PATH).new()
	add_child_autofree(v)
	return v


func test_constants_and_base_scale() -> void:
	var consts: Dictionary = load(PATH).get_script_constant_map()
	assert_almost_eq(float(consts.get("WOBBLE_SECONDS", 0.0)), 0.4, 0.0001)
	var v = _view()
	assert_eq(v.get("base_scale"), v.scale, "base_scale is the round size")
	v.set_tier(2)
	assert_eq(v.base_scale, v.scale, "set_tier updates base_scale")
	assert_eq(v.wobble_left, 0.0)


func test_wobble_squashes_then_settles() -> void:
	var v = _view()
	var base: Vector2 = v.base_scale
	v.wobble(0.3)
	assert_almost_eq(v.wobble_left, 0.4, 0.0001)
	v.advance_wobble(0.01)
	assert_gt(v.scale.x, base.x, "wider")
	assert_lt(v.scale.y, base.y, "and flatter right after the bounce")
	for i in 30:
		v.advance_wobble(0.02)
	assert_eq(v.wobble_left, 0.0)
	assert_eq(v.scale, base, "round again after 0.4 s")
	v.wobble(5.0)
	assert_almost_eq(v.wobble_strength, 0.5, 0.0001, "strength is capped at 0.5")
	v.advance_wobble(0.0)
	assert_gt(v.scale.y, 0.0, "never flips")


func test_bounces_wobble_the_alien() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	main.session.sim.bounced.emit(9.0)
	assert_almost_eq(main.projectile_view.wobble_left, 0.4, 0.0001, "a bounce starts a wobble")
	assert_almost_eq(main.projectile_view.wobble_strength, 0.35, 0.0001, "impact 9 m/s: 9 / 25 capped at 0.35")
	main.session.sim.bounced.emit(1.0)
	assert_almost_eq(main.projectile_view.wobble_strength, 0.08, 0.0001, "soft bounces still wobble a little")
	main.toggle_pause()
	await wait_seconds(0.5)
	assert_eq(main.projectile_view.scale, main.projectile_view.base_scale, "settles on its own with real frames")
