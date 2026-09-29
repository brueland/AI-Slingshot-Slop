extends GutTest
# Task 094: scripts/game/balloon_view.gd draws the shot's balloons; a pop hides the balloon, throws confetti,
# says "Pop!" and surprises the alien.

const PATH := "res://scripts/game/balloon_view.gd"
const BALLOONS := "res://scripts/core/balloons.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_094_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_view() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var v = load(PATH).new()
	add_child_autofree(v)
	var b = load(BALLOONS).new(load(BALLOONS).layout(5, 2000.0))
	v.build(b)
	assert_eq(v.points, b.points)
	assert_eq(v.visible_count(), b.points.size())
	v.pop(0)
	v.pop(0)
	v.pop(999)
	assert_eq(v.visible_count(), b.points.size() - 1)
	assert_false(v.shown[0])
	var base: Vector2 = WorldView.world_to_screen(b.points[1])
	assert_lt(v.screen_position(1).distance_to(base), 3.01, "bobs at most 3 px")
	assert_eq(v.ellipse(Vector2.ZERO, 14.0, 18.0).size(), 20)
	await wait_process_frames(3)
	pass_test("balloons draw without errors")


func test_main_shows_and_pops_balloons() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var v = main.get("balloon_view")
	assert_not_null(v, "main.balloon_view")
	if v == null:
		return
	assert_gt(v.get_index(), main.course_view.get_index())
	assert_lt(v.get_index(), main.projectile_view.get_index(), "behind the alien")
	assert_eq(main.feedback.balloon_view, v)
	main.start_game()
	assert_eq(v.points, main.session.balloons.points, "this shot's balloons")
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	main.session.balloons.popped.emit(0)
	assert_false(v.shown[0], "the balloon is gone")
	assert_eq(main.audio.last_sfx, "spring")
	assert_eq(main.projectile_view.decor.mood, "wow")
	var texts := []
	for c in main.popups.get_children():
		texts.append(c.text)
	assert_true(texts.has("Pop!"))
	var confetti := 0
	for c in main.effects.get_children():
		if c is CPUParticles2D and c.color_initial_ramp != null:
			confetti += 1
	assert_eq(confetti, 1)
