extends GutTest
# Task 142: a tip of the day at the bottom of the title screen (the same tip all day).

const PATH := "res://scripts/core/tips.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_142_save.json"


func before_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func after_each() -> void:
	before_each()


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func _main_in_flight():
	var main = _main()
	main.start_game()
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	main.advance(1.0 / 60.0)
	return main


func test_tips() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var t = load(PATH)
	assert_eq(t.LIST.size(), 10)
	var day := {"year": 2026, "month": 9, "day": 30}
	assert_eq(t.for_date(day), t.LIST[20260930 % 10])
	var main = _main()
	var label = main.ui_layer.get("tip_label")
	assert_true(label is Label, "ui_layer.tip_label")
	if not label is Label:
		return
	assert_true(label.visible)
	assert_eq(label.text, t.for_date(load("res://scripts/core/daily.gd").today()))
	await wait_process_frames(2)
	assert_true(main.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "on screen")
	assert_gt(label.get_global_rect().position.y, main.title_panel.bottom_bar.get_global_rect().end.y, "under the title's buttons (task 217)")
	main.start_game()
	assert_false(label.visible, "only on the title")
