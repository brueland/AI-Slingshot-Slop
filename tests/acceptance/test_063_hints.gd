extends GutTest
# Task 063: first-time hints at the bottom of the HUD: how to aim on the very first shot, and how to boost when
# the player has boosts, until they use one.

const HUD := "res://scripts/ui/hud.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_063_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)
const HINT_AIM := "Drag the alien back, aim, and let go!"
const HINT_BOOST := "Hold Space in the air to fire the rocket!"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func test_hud_hint_label() -> void:
	var consts: Dictionary = load(HUD).get_script_constant_map()
	assert_eq(consts.get("HINT_AIM"), HINT_AIM)
	assert_eq(consts.get("HINT_BOOST"), HINT_BOOST)
	var h = load(HUD).new()
	add_child_autofree(h)
	assert_true(h.get("hint_label") is Label, "hud.hint_label")
	if not h.get("hint_label") is Label:
		return
	assert_false(h.hint_label.visible, "hidden until needed")
	assert_eq(h.hint_label.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	h.show_hint("hello")
	assert_true(h.hint_label.visible)
	assert_eq(h.hint_label.text, "hello")
	await wait_process_frames(2)
	var screen: Rect2 = h.get_viewport().get_visible_rect()
	var r: Rect2 = h.hint_label.get_global_rect()
	assert_true(screen.encloses(r), "on screen")
	assert_almost_eq(r.get_center().x, screen.get_center().x, 2.0, "centered horizontally")
	assert_gt(r.position.y, screen.size.y * 0.5, "in the bottom half")
	h.hide_hint()
	assert_false(h.hint_label.visible)


func test_first_shot_shows_the_aim_hint() -> void:
	var main = _main()
	main.start_game()
	assert_true(main.hud.hint_label.visible)
	assert_eq(main.hud.hint_label.text, HINT_AIM)
	main.launch_with_pull(FULL_PULL_45)
	assert_false(main.hud.hint_label.visible, "gone once launched (no boosts to explain)")


func test_boost_hint_until_the_first_boost() -> void:
	var main = _main()
	main.progress.total_runs = 3
	main.progress.levels = {"boosts": 1}
	main.start_game()
	assert_false(main.hud.hint_label.visible, "no aim hint after the first run")
	main.launch_with_pull(FULL_PULL_45)
	assert_true(main.hud.hint_label.visible)
	assert_eq(main.hud.hint_label.text, HINT_BOOST)
	main.advance(1.0 / 60.0)
	main.request_boost()
	assert_false(main.hud.hint_label.visible, "hidden after boosting")
