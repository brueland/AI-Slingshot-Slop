extends GutTest
# Task 166: the Stats screen shows one more line: balloons popped, sheep woken and achievements earned.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_166_save.json"


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


func test_collection_line() -> void:
	var main = _main()
	main.progress.balloons_total = 12
	main.progress.sheep_woken = 5
	main.progress.achievements.append("liftoff")
	main.title_panel.stats_button.pressed.emit()
	var expected := "Balloons popped: 12   Sheep woken: 5   Achievements: 1/%d" % Achievements.LIST.size()
	assert_eq(main.stats_panel.collection_label.text, expected)
	assert_eq(main.stats_panel.collection_label.get_index(), main.stats_panel.rogue_total_label.get_index() + 1, "right under the roguelike total")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(main.stats_panel.get_global_rect()), "the stats still fit")
