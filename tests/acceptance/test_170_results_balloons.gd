extends GutTest
# Task 170: the results show "Balloons popped: N" when the shot popped any balloons.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_170_save.json"


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


func test_results_balloons() -> void:
	var main = _main()
	main.start_game()
	_busy_shot(main)
	var label = main.results_panel.balloons_label
	assert_true(label.visible)
	assert_eq(label.text, "Balloons popped: %d" % int(main.last_result["balloons"]))
	assert_eq(label.get_index(), main.results_panel.hats_label.get_index() + 1, "right under the hats line")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(main.results_panel.get_global_rect()), "the results still fit")
	main.results_panel.show_result(main.last_result.merged({"balloons": 0}, true), false)
	assert_false(label.visible, "hidden when no balloon popped")
