extends GutTest
# Checkpoint 27 (task 213c): faces and sky work together with real frames: the mascot smiles and is surprised when
# poked, the alien makes flying faces, the sky follows the climb, and a finished flight ends in a sleepy face.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_213c_save.json"
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


func test_faces_and_sky_with_real_frames() -> void:
	var main = _main()
	await wait_seconds(0.3)
	var mascot = main.title_panel.mascot
	assert_eq(mascot.decor.shown_face(), "happy")
	mascot.poke()
	assert_eq(mascot.decor.shown_face(), "wow")
	main.start_game()
	main.launch_with_pull(PULL)
	await wait_seconds(0.3)
	var decor = main.projectile_view.decor
	assert_true(["wee", "happy", "scared", "wow", "ouch"].has(decor.shown_face()), "a flying face: " + decor.shown_face())
	assert_gt(main.background.sky_gradient.height, 0.5, "the sky follows the flight")
	assert_almost_eq(decor.scale.x, 1.5, 0.0001)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	await wait_seconds(0.2)
	assert_eq(decor.shown_face(), "sleepy", "resting after the flight")


func test_new_code_follows_the_conventions() -> void:
	var names := {"res://scripts/game/alien_face.gd": "AlienFace", "res://scripts/game/sky_gradient.gd": "SkyGradient"}
	for path in names:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + names[path]), path)
		assert_false(text.contains("print("), path)
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_27() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 27: complete"), "add the line 'Milestone 27: complete' to docs/PROGRESS.md")
