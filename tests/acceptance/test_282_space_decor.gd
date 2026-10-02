extends GutTest
# Task 282: scripts/game/space_decor.gd: things in space that fade in at their own heights as the alien climbs (a
# satellite from 90 m, a planet and a moon from 120 m, comets from 150 m, asteroids from 180 m, an astronaut from
# 250 m); none of it near the ground.

const PATH := "res://scripts/game/space_decor.gd"


func test_space_decor() -> void:
	var s = load(PATH)
	assert_eq(s.showing(50.0), [], "nothing near the ground")
	assert_eq(s.showing(100.0), ["satellite"])
	assert_eq(s.showing(300.0).size(), 6, "everything up high")
	assert_eq(s.alpha_for("planet", 120.0), 0.0)
	assert_almost_eq(s.alpha_for("planet", 150.0), 0.5, 0.0001, "fading in over 60 m")
	assert_eq(s.alpha_for("planet", 400.0), 1.0)
	var d = s.new()
	add_child_autofree(d)
	d.set_height(20.0)
	assert_false(d.visible)
	d.set_height(300.0)
	assert_true(d.visible)
	var p: Vector2 = d.satellite_position()
	d.time += 4.0
	assert_ne(d.satellite_position(), p, "the satellite drifts")
	d.time = 1.5
	assert_almost_eq(d.comet_progress(), 0.5, 0.0001, "a comet half way across")
	d.time = 5.0
	assert_eq(d.comet_progress(), -1.0, "and a pause between comets")
	await wait_process_frames(3)
