extends GutTest
# Task 028: scripts/game/camera_rig.gd, a Camera2D that keeps the projectile in view with the ground
# near the bottom of the screen.

const PATH := "res://scripts/game/camera_rig.gd"


func _cr():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_desired_position() -> void:
	var cr = _cr()
	if cr == null:
		return
	var view := Vector2(1280, 720)
	assert_eq(cr.desired_position(Vector2(0, 0), view), Vector2(320, -260),
		"x = target.x + 25% of the view width; ground 100 px above the bottom")
	assert_eq(cr.desired_position(Vector2(500, -100), view), Vector2(820, -260), "low targets keep the ground view")
	assert_eq(cr.desired_position(Vector2(500, -1000), view), Vector2(820, -856), "high targets: y = target.y + 20% of the view height")


func test_snap_and_follow() -> void:
	var cr = _cr()
	if cr == null:
		return
	var cam = cr.new()
	add_child_autofree(cam)
	assert_true(cam is Camera2D)
	assert_eq(cam.view_size, Vector2(1280, 720))
	assert_almost_eq(cam.follow_speed, 5.0, 0.0001)
	cam.snap_to(Vector2(0, 0))
	assert_eq(cam.position, Vector2(320, -260))
	cam.follow(Vector2(400, 0), 0.1)
	assert_almost_eq(cam.position.x, 520.0, 0.001, "moves 5 * 0.1 = 50% of the way to 720")
	cam.follow(Vector2(400, 0), 10.0)
	assert_almost_eq(cam.position.x, 720.0, 0.001, "the lerp weight is clamped to 1")
