extends GutTest
# Task 198: StarRating, one to three stars for a shot.

const PATH := "res://scripts/ui/star_rating.gd"


func test_star_rating() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var script = load(PATH)
	assert_eq(script.rating_for(120.0, 100.0), 3, "a new best")
	assert_eq(script.rating_for(80.0, 100.0), 2, "at least 75% of the best")
	assert_eq(script.rating_for(74.0, 100.0), 1)
	assert_eq(script.rating_for(5.0, 0.0), 3, "the first shot is a new best")
	var points: PackedVector2Array = script.star_points(Vector2(10, 10), 14.0)
	assert_eq(points.size(), 10)
	assert_almost_eq(points[0], Vector2(10, -4), Vector2(0.001, 0.001), "the top point")
	var stars = script.new()
	add_child_autofree(stars)
	stars.set_rating(5)
	assert_eq(stars.rating, 3, "at most 3")
	stars.set_rating(2)
	assert_eq(stars.rating, 2)
	await wait_process_frames(2)
	pass_test("the stars draw without errors")
