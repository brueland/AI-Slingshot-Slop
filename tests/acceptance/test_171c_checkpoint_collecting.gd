extends GutTest
# Checkpoint 20 (task 171c): collecting works together with real frames: a busy shot's balloons and sheep reach the
# results and the Stats screen, the wardrobe's surprise and hover previews agree, and a poked mascot lands again.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_171c_save.json"


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


## A classic shot where two balloons count as popped and three sheep as woken, flown to the end.
func _busy_shot(main) -> void:
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	main.advance(1.0 / 60.0)
	main.session.balloons.popped_count = 2
	main.feedback.sheep_woken_run = 3
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_collecting_with_real_frames() -> void:
	var main = _main()
	main.start_game()
	_busy_shot(main)
	await wait_seconds(0.3)
	assert_true(main.results_panel.balloons_label.visible)
	var balloons: int = main.progress.balloons_total
	main.go_to_title()
	main.title_panel.stats_button.pressed.emit()
	assert_true(main.stats_panel.collection_label.text.begins_with("Balloons popped: %d   Sheep woken: %d" % [balloons, main.progress.sheep_woken]))
	main.stats_panel.hide()
	main.title_panel.wardrobe_button.pressed.emit()
	var panel = main.wardrobe_panel
	panel.surprise_button.pressed.emit()
	var hat: String = main.progress.hat
	assert_ne(hat, "none", "the first run unlocked a hat to surprise with")
	assert_eq(panel.worn, hat)
	panel.hat_buttons["none"].mouse_entered.emit()
	panel.hat_buttons["none"].mouse_exited.emit()
	assert_eq(panel.preview.decor.hat, hat)
	panel.close_button.pressed.emit()
	main.title_panel.mascot.poke()
	await wait_seconds(0.6)
	assert_eq(main.title_panel.mascot.poke_left, 0.0, "the mascot lands again")


func test_new_code_follows_the_conventions() -> void:
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")
	for path in ["res://scripts/ui/wardrobe_panel.gd", "res://scripts/ui/title_mascot.gd"]:
		assert_false(FileAccess.get_file_as_string(path).contains("print("), path)


func test_progress_log_records_milestone_20() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 20: complete"), "add the line 'Milestone 20: complete' to docs/PROGRESS.md")
