extends GutTest
# Task 212: the title's buttons come in pairs (Roguelike | Daily Run, Wardrobe | Stats, Options | Credits), so the
# title is short enough to stay clear of the daily challenge and tip lines at the bottom of the screen.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_212_save.json"
const PULL := Vector2(-84.852814, 84.852814)


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


func test_title_pairs() -> void:
	var main = _main()
	var t = main.title_panel
	for pair in [[t.rogue_button, t.daily_button], [t.wardrobe_button, t.stats_button], [t.options_button, t.credits_button]]:
		assert_true(pair[0].get_parent() is HBoxContainer, pair[0].text + " is in a row")
		assert_eq(pair[0].get_parent(), pair[1].get_parent(), pair[0].text + " and " + pair[1].text + " side by side")
		assert_eq(pair[0].get_index(), 0, pair[0].text + " on the left")
	assert_eq(t.play_button.get_parent(), t.box, "Play keeps its own row")
	assert_eq(t.reset_button.get_parent(), t.box, "so does Reset progress")
	var order := [t.play_button, t.rogue_button.get_parent(), t.wardrobe_button.get_parent(), t.help_button.get_parent(),
		t.options_button.get_parent(), t.reset_button]
	for i in range(1, order.size()):
		assert_gt(order[i].get_index(), order[i - 1].get_index(), "rows in order")
	main.progress.best_rogue_round = 5
	main.ui_layer.refresh(main)
	t.show_greeting("Happy Halloween!")
	await wait_process_frames(3)
	var rect: Rect2 = t.get_global_rect()
	assert_true(main.get_viewport().get_visible_rect().encloses(rect), "on screen")
	assert_lt(rect.end.y, main.ui_layer.challenge_label.get_global_rect().position.y, "clear of the daily challenge line")
	assert_lt(rect.end.y, main.ui_layer.tip_label.get_global_rect().position.y, "clear of the tip line")
	watch_signals(t)
	t.credits_button.pressed.emit()
	assert_signal_emitted(t, "credits_pressed", "the buttons still work")
