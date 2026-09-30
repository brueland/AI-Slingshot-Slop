extends GutTest
# Task 182: CourseBar, a thin bar showing how far the alien is on the way to 1000 m, with the best distance marked.

const PATH := "res://scripts/ui/course_bar.gd"


func test_course_bar() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var script = load(PATH)
	assert_eq(script.fraction_for(250.0), 0.25)
	assert_eq(script.fraction_for(5000.0), 1.0)
	assert_eq(script.fraction_for(-3.0), 0.0)
	var bar = script.new()
	add_child_autofree(bar)
	bar.set_distance(100.0)
	assert_almost_eq(bar.fraction, 0.1, 0.0001)
	bar.set_best(500.0)
	assert_almost_eq(bar.best_fraction, 0.5, 0.0001)
	assert_eq(bar.custom_minimum_size, Vector2(400, 8))
	await wait_process_frames(2)
	pass_test("the bar draws without errors")
