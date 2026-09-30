extends GutTest
# Task 024: scripts/game/projectile_view.gd draws the alien projectile where the FlightSim says it is.

const PATH := "res://scripts/game/projectile_view.gd"
const SIM_PATH := "res://scripts/core/flight_sim.gd"


func _view():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	var v = load(PATH).new()
	add_child_autofree(v)
	return v


func test_is_a_sprite_with_the_first_alien() -> void:
	var v = _view()
	if v == null:
		return
	assert_true(v is Sprite2D)
	assert_eq(v.tier, 0)
	assert_not_null(v.texture)
	if v.texture != null:
		assert_eq(v.texture.resource_path, "res://assets/sprites/projectile_1.png")
	# 2 * PROJECTILE_RADIUS m * 16 px/m * LOOK_SCALE (1.5) = 36 px wide; the texture is 70 px (updated by task 205)
	assert_almost_eq(v.scale.x, 36.0 / 70.0, 0.001)
	assert_almost_eq(v.scale.y, 36.0 / 70.0, 0.001)


func test_show_at_sits_on_the_ground() -> void:
	var v = _view()
	if v == null:
		return
	v.show_at(Vector2(10, 0))
	assert_eq(v.position, Vector2(160, -18), "center is PROJECTILE_RADIUS * LOOK_SCALE (18 px) above the ground")


func test_sync_from_sim_moves_and_rolls() -> void:
	var v = _view()
	if v == null:
		return
	var sim = load(SIM_PATH).new()
	sim.launch(Vector2(3, 5), Vector2(10, 0))
	v.sync_from(sim)
	assert_almost_eq(v.position.x, 48.0, 0.001)
	assert_almost_eq(v.position.y, -98.0, 0.001, "-(5 + 0.75 * 1.5) * 16")
	assert_almost_eq(v.rotation, 4.0, 0.0001, "rotation = x / PROJECTILE_RADIUS (rolling)")


func test_set_tier() -> void:
	var v = _view()
	if v == null:
		return
	v.set_tier(2)
	assert_eq(v.tier, 2)
	assert_eq(v.texture.resource_path, "res://assets/sprites/projectile_3.png")
	v.set_tier(7)
	assert_eq(v.tier, 2, "clamped to 0..2")
	v.set_tier(1)
	assert_eq(v.texture.resource_path, "res://assets/sprites/projectile_2.png")
