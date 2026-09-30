extends GutTest
# Task 162: milestone flags glow gold once their distance is reached.


func test_reached_flags() -> void:
	var cv = load("res://scripts/game/course_view.gd").new()
	add_child_autofree(cv)
	var first := float(Milestones.LIST[0]["distance"])
	cv.set_best_marker(first)
	assert_eq(cv.flags[0].modulate, Color(1.0, 0.9, 0.4), "reached")
	assert_eq(cv.flags[1].modulate, Color.WHITE, "not yet")
	cv.set_best_marker(0.0)
	assert_eq(cv.flags[0].modulate, Color.WHITE)
