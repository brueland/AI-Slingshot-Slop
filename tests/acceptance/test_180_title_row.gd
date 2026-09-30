extends GutTest
# Task 180: the title screen gets a row with two buttons, "How to play" and "Achievements", under Stats.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_180_save.json"
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


func test_title_row() -> void:
	var main = _main()
	var title = main.title_panel
	assert_eq(title.help_button.text, "How to play")
	assert_eq(title.achievements_button.text, "Achievements")
	var row = title.help_button.get_parent()
	assert_true(row is HBoxContainer, "side by side")
	assert_eq(title.achievements_button.get_parent(), row)
	assert_eq(row.get_index(), title.stats_button.get_parent().get_index() + 1, "right under the Stats row (task 212)")
	watch_signals(title)
	title.help_button.pressed.emit()
	assert_signal_emitted(title, "help_pressed")
	title.achievements_button.pressed.emit()
	assert_signal_emitted(title, "achievements_pressed")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(title.get_global_rect()), "the title still fits on screen")
