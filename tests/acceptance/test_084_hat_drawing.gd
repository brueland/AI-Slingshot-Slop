extends GutTest
# Task 084: scripts/game/projectile_decor.gd draws the alien's hat. It is a top_level child of ProjectileView,
# so it follows the alien but stays upright while the alien rolls.

const DECOR := "res://scripts/game/projectile_decor.gd"
const VIEW := "res://scripts/game/projectile_view.gd"
const HATS := "res://scripts/core/hats.gd"


func _view():
	var v = load(VIEW).new()
	add_child_autofree(v)
	return v


func test_view_owns_a_decor() -> void:
	if not ResourceLoader.exists(DECOR):
		fail_test("missing file " + DECOR)
		return
	var v = _view()
	var d = v.get("decor")
	assert_not_null(d, "ProjectileView.decor")
	if d == null:
		return
	assert_eq(d.get_script().resource_path, DECOR)
	assert_eq(d.get_parent(), v)
	assert_true(d.top_level, "top_level: it does not roll with the alien")
	assert_eq(d.hat, "none")


func test_set_hat() -> void:
	if not ResourceLoader.exists(DECOR):
		fail_test("missing file " + DECOR)
		return
	var v = _view()
	v.set_hat("party")
	assert_eq(v.decor.hat, "party")
	v.set_hat("sombrero")
	assert_eq(v.decor.hat, "none", "unknown hats are not worn")


func test_follows_the_alien_and_stays_upright() -> void:
	if not ResourceLoader.exists(DECOR):
		fail_test("missing file " + DECOR)
		return
	var v = _view()
	v.set_hat("top_hat")
	v.show_at(Vector2(10.0, 3.0))
	v.rotation = 2.5
	await wait_process_frames(2)
	assert_almost_eq(v.decor.global_position.x, v.global_position.x, 0.01)
	assert_almost_eq(v.decor.global_position.y, v.global_position.y, 0.01)
	assert_almost_eq(v.decor.global_rotation, 0.0, 0.0001, "the hat stays upright")
	v.hide()
	await wait_process_frames(2)
	assert_false(v.decor.visible, "hidden with the alien")


func test_every_hat_draws() -> void:
	if not ResourceLoader.exists(DECOR):
		fail_test("missing file " + DECOR)
		return
	var v = _view()
	for entry in load(HATS).LIST:
		v.set_hat(entry["id"])
		await wait_process_frames(2)
	var pts: PackedVector2Array = load(DECOR).dome(Vector2(0, 0), 8.0)
	assert_eq(pts.size(), 13)
	for p in pts:
		assert_lt(p.y, 0.0001, "a dome is the upper half")
	pass_test("all hats drew without errors")
