extends GutTest
# Task 070: scripts/ui/toast.gd shows short messages at the top of the screen, one at a time for 3 s; main.gd
# announces every unlocked achievement with one.

const PATH := "res://scripts/ui/toast.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_070_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_toast_queue() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var t = load(PATH).new()
	add_child_autofree(t)
	assert_true(t is PanelContainer)
	assert_eq(t.mouse_filter, Control.MOUSE_FILTER_IGNORE, "never blocks clicks")
	assert_false(t.visible)
	t.enqueue("First", "one")
	t.enqueue("Second", "two")
	assert_true(t.visible)
	assert_eq(t.title_label.text, "First")
	assert_eq(t.text_label.text, "one")
	t.advance(1.0)
	assert_eq(t.title_label.text, "First", "each message stays 3 s")
	t.advance(2.1)
	assert_true(t.visible)
	assert_eq(t.title_label.text, "Second")
	t.advance(3.1)
	assert_false(t.visible, "hidden when the queue is empty")


func test_toast_sits_at_the_top_center() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var t = load(PATH).new()
	add_child_autofree(t)
	t.enqueue("Achievement unlocked: Liftoff", "Finish your first run")
	await wait_process_frames(3)
	var screen: Rect2 = t.get_viewport().get_visible_rect()
	var r: Rect2 = t.get_global_rect()
	assert_true(screen.encloses(r), "on screen: %s" % r)
	assert_almost_eq(r.get_center().x, screen.get_center().x, 3.0, "centered horizontally")
	assert_lt(r.position.y, 60.0, "at the top")


func test_main_announces_achievements() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var toast = main.get("toast")
	assert_not_null(toast, "main.toast")
	if toast == null:
		return
	assert_eq(toast, main.ui_layer.toast, "built by UiRoot")
	assert_eq(toast.theme, main.ui_theme, "themed")
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	assert_true(toast.visible)
	assert_eq(toast.title_label.text, "Achievement unlocked: Liftoff")
	assert_eq(toast.text_label.text, "Finish your first run")
