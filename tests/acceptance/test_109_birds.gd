extends GutTest
# Task 109: scripts/game/birds.gd, little birds perched in the sky along the course. When the alien flies within
# 90 px they scatter up and away with a "Tweet!"; every new shot puts them back on their perches.

const PATH := "res://scripts/game/birds.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_109_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _script():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_layout() -> void:
	var b = _script()
	if b == null:
		return
	var pts: Array = b.layout(23, 2000.0)
	assert_eq(pts, b.layout(23, 2000.0), "same seed, same birds")
	assert_gt(pts.size(), 10)
	var previous := 30.0
	for p in pts:
		assert_between(p.x - previous, 50.0, 120.0)
		assert_between(p.y, 6.0, 16.0)
		previous = p.x


func test_scare_and_fly() -> void:
	var b = _script()
	if b == null:
		return
	var birds = b.new()
	add_child_autofree(birds)
	assert_eq(birds.perches, b.layout(23, 2000.0))
	assert_false(birds.flying[0])
	var at: Vector2 = birds.bird_position(0)
	assert_eq(birds.scare_near(at + Vector2(200, 0)), 0, "too far away")
	assert_eq(birds.scare_near(at + Vector2(50, 20)), 1)
	assert_true(birds.flying[0])
	var tweets := 0
	for c in birds.get_children():
		if c is FloatingText and c.text == "Tweet!":
			tweets += 1
	assert_eq(tweets, 1, "a Tweet! pops up")
	assert_eq(birds.scare_near(at), 0, "a flying bird is not scared again")
	birds.advance(0.5)
	assert_eq(birds.offsets[0], Vector2(70.0, -100.0), "flies up and away")
	assert_eq(birds.offsets[1], Vector2.ZERO, "the others stay perched")
	birds.reset()
	assert_false(birds.flying[0])
	assert_eq(birds.offsets[0], Vector2.ZERO)
	await wait_process_frames(2)
	pass_test("the birds draw without errors")


func test_birds_in_the_game() -> void:
	if _script() == null:
		return
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var birds = main.get("birds")
	assert_not_null(birds, "main.birds")
	if birds == null:
		return
	assert_eq(birds.target, main.projectile_view, "they watch the alien")
	assert_lt(birds.get_index(), main.course_view.get_index(), "behind the course items")
	main.start_game()
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	main.advance(1.0 / 60.0)
	main.toggle_pause()
	main.projectile_view.position = birds.bird_position(0)
	await wait_process_frames(2)
	assert_true(birds.flying[0], "the alien flew close, so the bird scattered")
	main.toggle_pause()
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.continue_to_shop()
	main.leave_shop()
	assert_false(birds.flying[0], "a new shot brings the birds back")
