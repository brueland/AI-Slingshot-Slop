extends GutTest
# Checkpoint 24 (task 195c): the sky decorations work together with real frames: the windsock flaps and points with a
# roguelike tailwind, and the hot-air balloons drift during a flight.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_195c_save.json"


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


## The first child of `main` whose script has class_name `name` (null when there is none).
func _find(main, name: String):
	for child in main.get_children():
		var script = child.get_script()
		if script != null and script.get_global_name() == name:
			return child
	return null


func test_sky_with_real_frames() -> void:
	var main = _main()
	var sock = _find(main, "WindSock")
	var sky = _find(main, "SkyBalloons")
	main.start_rogue(5)
	main.rogue.weather = "tailwind"
	main._begin_aim()
	var tip: Vector2 = sock.tip_offset()
	var drift: Vector2 = sky.balloon_position_m(1)
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	await wait_seconds(0.6)
	assert_eq(sock.direction, 1.0)
	assert_ne(sock.tip_offset(), tip, "the windsock flaps with real frames")
	assert_gt(sky.balloon_position_m(1).x, drift.x, "the balloons drift")


func test_new_scripts_follow_the_conventions() -> void:
	var names := {"res://scripts/game/wind_sock.gd": "WindSock", "res://scripts/game/sky_balloons.gd": "SkyBalloons"}
	for path in names:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + names[path]), path)
		assert_false(text.contains("print("), path)
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_24() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 24: complete"), "add the line 'Milestone 24: complete' to docs/PROGRESS.md")
