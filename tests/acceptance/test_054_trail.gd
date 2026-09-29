extends GutTest
# Task 054: scripts/game/trail.gd, a fading Line2D behind the flying projectile; main.gd adds a point every
# flight step and clears it for the next shot.

const PATH := "res://scripts/game/trail.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_054_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_trail_keeps_the_last_30_points() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var t = load(PATH).new()
	add_child_autofree(t)
	assert_true(t is Line2D)
	assert_almost_eq(t.width, 8.0, 0.001)
	assert_true(t.gradient is Gradient, "fades out with a gradient")
	if t.gradient is Gradient:
		assert_lt(t.gradient.get_color(0).a, t.gradient.get_color(t.gradient.get_point_count() - 1).a,
			"the oldest end is the most transparent")
	for i in 45:
		t.add_trail_point(Vector2(i, -i))
	assert_eq(t.get_point_count(), 30)
	assert_eq(t.get_point_position(0), Vector2(15, -15), "the oldest points are dropped")
	assert_eq(t.get_point_position(29), Vector2(44, -44))
	t.clear_trail()
	assert_eq(t.get_point_count(), 0)


func test_main_draws_a_trail_during_flight() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var trail = main.get("trail")
	assert_not_null(trail, "main.trail")
	if trail == null:
		return
	assert_lt(trail.get_index(), main.projectile_view.get_index(), "the trail is drawn behind the projectile")
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 50:
		main.advance(1.0 / 60.0)
	assert_eq(trail.get_point_count(), 30)
	assert_eq(trail.get_point_position(29), main.projectile_view.position, "the newest point is the projectile")
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.continue_to_shop()
	main.leave_shop()
	assert_eq(trail.get_point_count(), 0, "a new shot starts without a trail")
