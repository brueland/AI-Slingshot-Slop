extends GutTest
# Task 100: twinkling stars (scripts/game/star_field.gd) in their own sky layer. Hidden near the ground, they fade in
# from 40 m and are fully visible from 150 m up.

const PATH := "res://scripts/game/star_field.gd"
const BG := "res://scripts/game/background.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_100_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _s():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_fade_by_height() -> void:
	var s = _s()
	if s == null:
		return
	assert_eq(s.alpha_for_height(0.0), 0.0)
	assert_eq(s.alpha_for_height(40.0), 0.0)
	assert_almost_eq(s.alpha_for_height(95.0), 0.5, 0.0001)
	assert_eq(s.alpha_for_height(150.0), 1.0)
	assert_eq(s.alpha_for_height(900.0), 1.0)


func test_star_field() -> void:
	var s = _s()
	if s == null:
		return
	var f = s.new()
	add_child_autofree(f)
	assert_eq(f.stars.size(), 90)
	assert_eq(f.modulate.a, 0.0, "hidden at first")
	var again = s.new()
	add_child_autofree(again)
	assert_eq(again.stars, f.stars, "the same sky every time")
	f.set_height(150.0)
	assert_eq(f.modulate.a, 1.0)
	await wait_process_frames(3)
	assert_gt(f.time, 0.0, "twinkles while visible")


func test_sky_has_a_star_layer() -> void:
	if _s() == null:
		return
	var bg = load(BG).new()
	add_child_autofree(bg)
	assert_eq(bg.layers.size(), 2, "the sky and cloud layers are unchanged")
	assert_true(bg.get("stars_layer") is Parallax2D, "background.stars_layer")
	assert_eq(bg.star_field.get_parent(), bg.stars_layer)
	bg.set_altitude(95.0)
	assert_almost_eq(bg.star_field.modulate.a, 0.5, 0.0001)
	bg.set_altitude(0.0)
	assert_eq(bg.star_field.modulate.a, 0.0)


func test_stars_come_out_on_a_high_flight() -> void:
	if _s() == null:
		return
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.progress.levels = {"power": 5}
	main.start_game()
	main.launch_with_pull(Vector2(-10, 119))
	var peak := 0.0
	for i in 600:
		main.advance(1.0 / 60.0)
		peak = maxf(peak, main.background.star_field.modulate.a)
		if main.state_name() != "FLIGHT":
			break
	assert_gt(peak, 0.1, "stars shine at the top of a steep, strong shot")
