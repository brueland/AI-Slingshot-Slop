extends GutTest
# Task 122: stars on the course gently pulse and the milestone flags sway.

const PATH := "res://scripts/game/course_view.gd"
const ITEMS := [{"type": "star", "x": 40.0, "y": 5.0}, {"type": "spring", "x": 100.0, "y": 0.0}, {"type": "star", "x": 60.0, "y": 4.0}]


func test_twinkle_and_wave() -> void:
	var cv = load(PATH).new()
	add_child_autofree(cv)
	cv.build(ITEMS)
	assert_eq(cv.get("star_indices"), [0, 2], "the stars of the course")
	assert_eq(cv.sprites[0].scale, Vector2(0.5, 0.5), "stars start at their normal size")
	cv.advance(0.3)
	assert_ne(cv.sprites[0].scale, Vector2(0.5, 0.5), "then pulse")
	assert_between(cv.sprites[0].scale.x, 0.45, 0.55)
	assert_eq(cv.sprites[1].scale, Vector2(0.6, 0.6), "springs don't pulse")
	for f in cv.flags:
		assert_between(f.rotation, -0.061, 0.061, "flags sway a little")
	assert_ne(cv.flags[0].rotation, 0.0)
	cv.build([])
	assert_eq(cv.star_indices, [], "a new course forgets the old stars")
	await wait_process_frames(2)
	pass_test("animates without errors")
