extends GutTest
# Task 145: screen shake can be turned off: CameraRig.shake_enabled, and Progress.shake_on (saved, on by default).


func test_shake_setting() -> void:
	var cam = load("res://scripts/game/camera_rig.gd").new()
	add_child_autofree(cam)
	assert_true(cam.shake_enabled)
	cam.shake(5.0, 0.5)
	assert_true(cam.is_shaking())
	cam.shake_time_left = 0.0
	cam.shake_enabled = false
	cam.shake(5.0, 0.5)
	assert_false(cam.is_shaking(), "no shake when turned off")
	var script = load("res://scripts/core/progress.gd")
	var p = script.new()
	assert_true(p.shake_on)
	p.shake_on = false
	var q = script.from_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	assert_false(q.shake_on)
	assert_true(script.from_dict({}).shake_on, "old saves shake")
