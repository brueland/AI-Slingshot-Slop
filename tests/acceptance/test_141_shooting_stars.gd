extends GutTest
# Task 141: while the night stars are out, a shooting star crosses the sky every 3 seconds.

const PATH := "res://scripts/game/star_field.gd"


func test_shooting_stars() -> void:
	var f = load(PATH).new()
	add_child_autofree(f)
	assert_eq(f.get("shooting"), [])
	f.set_height(150.0)
	for i in 31:
		f._process(0.1)
	assert_eq(f.shooting.size(), 1, "one shooting star after 3 seconds")
	var head: Vector2 = f.shooting_position(f.shooting[0])
	for i in 5:
		f._process(0.1)
	assert_gt(f.shooting_position(f.shooting[0]).x, head.x, "it flies across the sky")
	for i in 8:
		f._process(0.1)
	assert_eq(f.shooting.size(), 0, "gone after 1 second")
	f.set_height(0.0)
	for i in 40:
		f._process(0.1)
	assert_eq(f.shooting.size(), 0, "none while the stars are hidden")
	await wait_process_frames(2)
