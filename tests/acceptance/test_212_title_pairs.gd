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
	# Updated by task 217: the mode buttons moved into the mode chooser, the others into the bottom bar
	for button in [t.wardrobe_button, t.stats_button, t.achievements_button, t.help_button, t.options_button, t.credits_button]:
		assert_eq(button.get_parent(), t.bottom_bar, button.text + " is in the bottom bar")
	assert_eq(t.play_button.get_parent().get_parent(), t.rogue_button.get_parent().get_parent(), "the modes share a list")
	main.progress.best_rogue_round = 5
	main.ui_layer.refresh(main)
	t.show_greeting("Happy Halloween!")
	await wait_process_frames(3)
	var rect: Rect2 = t.bottom_bar.get_global_rect()
	assert_true(main.get_viewport().get_visible_rect().encloses(rect), "on screen")
	assert_lt(rect.end.y, main.ui_layer.challenge_label.get_global_rect().position.y, "clear of the daily challenge line")
	assert_lt(rect.end.y, main.ui_layer.tip_label.get_global_rect().position.y, "clear of the tip line")
	watch_signals(t)
	t.credits_button.pressed.emit()
	assert_signal_emitted(t, "credits_pressed", "the buttons still work")
