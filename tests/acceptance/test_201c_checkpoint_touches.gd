extends GutTest
# Checkpoint 25 (task 201c): the last touches work together with real frames: the speed readout during a real flight,
# the stars on the results, and a greeting on the title.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_201c_save.json"
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


func _fly(main, pull: Vector2) -> void:
	main.launch_with_pull(pull)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_last_touches_with_real_frames() -> void:
	var main = _main()
	main.title_panel.show_greeting("Merry Christmas!")
	main.start_game()
	main.launch_with_pull(PULL)
	await wait_seconds(0.5)
	assert_ne(main.hud.speed_label.text, "Speed: 0 m/s", "the speed follows a real flight")
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	await wait_seconds(0.2)
	assert_eq(main.results_panel.rating.rating, 3)
	main.go_to_title()
	assert_true(main.title_panel.greeting_label.visible)


func test_new_scripts_follow_the_conventions() -> void:
	var names := {"res://scripts/core/greetings.gd": "Greetings", "res://scripts/ui/star_rating.gd": "StarRating"}
	for path in names:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + names[path]), path)
		assert_false(text.contains("print("), path)
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_25() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 25: complete"), "add the line 'Milestone 25: complete' to docs/PROGRESS.md")
