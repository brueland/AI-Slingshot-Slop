extends GutTest
# Task 150: the Stats screen shows "Best combo: xN".

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_150_save.json"


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


func _fly(main, pull: Vector2) -> void:
	main.launch_with_pull(pull)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_combo_stat() -> void:
	var main = _main()
	main.progress.best_combo = 6
	main.title_panel.stats_button.pressed.emit()
	var label = main.stats_panel.get("combo_label")
	assert_true(label is Label, "stats_panel.combo_label")
	if not label is Label:
		return
	assert_eq(label.text, "Best combo: x6")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(main.stats_panel.get_global_rect()), "the stats still fit")
