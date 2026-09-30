extends GutTest
# Task 123: the aim preview's dots fade out along the arc (0.9 next to the slingshot, 0.2 at the far end).

const PATH := "res://scripts/game/trajectory_preview.gd"


func test_dot_alpha() -> void:
	var t = load(PATH)
	assert_almost_eq(t.dot_alpha(0, 10), 0.9, 0.0001)
	assert_almost_eq(t.dot_alpha(9, 10), 0.2, 0.0001)
	assert_almost_eq(t.dot_alpha(3, 7), 0.55, 0.0001)
	assert_almost_eq(t.dot_alpha(0, 1), 0.9, 0.0001, "a single dot is clear")
	var p = t.new()
	add_child_autofree(p)
	p.update_preview(Vector2(0, 2), Vector2(15, 15), 0.002, 12)
	await wait_process_frames(2)
	pass_test("draws without errors")
