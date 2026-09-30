extends GutTest
# Checkpoint 18 (task 156c): the final polish works together with real frames: the party hat's rainbow trail follows a
# flight while the height bar rises, the sheep graze, and the title mascot hops.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_156c_save.json"


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


func test_polish_with_real_frames() -> void:
	var main = _main()
	main.progress.total_runs = 1
	main.choose_hat("party")
	await wait_seconds(0.5)
	assert_gt(main.title_panel.mascot.time, 0.4, "the mascot keeps its time running")
	main.start_game()
	assert_eq(main.trail.style, "party")
	var head: float = main.critters.head_bob(0)
	main.launch_with_pull(Vector2(-10, 119))
	for i in 30:
		main.advance(1.0 / 60.0)
	await wait_seconds(0.4)
	assert_gt(main.trail.get_point_count(), 5, "the rainbow trail follows the flight")
	assert_gt(main.hud.altitude_bar.value, 0.0)
	assert_ne(main.critters.head_bob(0), head, "the sheep graze with real frames")


func test_new_scripts_follow_the_conventions() -> void:
	var path := "res://scripts/ui/altitude_bar.gd"
	if not ResourceLoader.exists(path):
		fail_test("missing file " + path)
		return
	var text := FileAccess.get_file_as_string(path)
	assert_true(text.contains("class_name AltitudeBar"))
	assert_false(text.contains("print("))
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_18() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 18: complete"), "add the line 'Milestone 18: complete' to docs/PROGRESS.md")
