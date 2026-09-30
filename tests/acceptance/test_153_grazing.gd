extends GutTest
# Task 153: the sheep graze: their heads dip down (0-3 px) now and then.


func test_grazing() -> void:
	var c = load("res://scripts/game/critters.gd").new()
	add_child_autofree(c)
	c.build(11, 2000.0)
	var seen := {}
	for i in 40:
		c.advance(0.1)
		var b: float = c.head_bob(0)
		assert_between(b, 0.0, 3.0)
		seen[snappedf(b, 0.1)] = true
	assert_gt(seen.size(), 5, "the head moves")
	await wait_process_frames(2)
	pass_test("grazing sheep draw without errors")
