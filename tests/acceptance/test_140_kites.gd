extends GutTest
# Task 140: three kites on long strings near the start, swaying in the breeze.

const PATH := "res://scripts/game/kites.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_140_save.json"


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


func _main_in_flight():
	var main = _main()
	main.start_game()
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	main.advance(1.0 / 60.0)
	return main


func test_kites() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var k = load(PATH).new()
	add_child_autofree(k)
	var before: Vector2 = k.kite_position(0)
	k.advance(1.0)
	assert_ne(k.kite_position(0), before, "kites sway")
	var anchor := WorldView.world_to_screen(Vector2(18.0, 0.0))
	assert_lt(k.kite_position(0).y, anchor.y - 150.0, "high above the ground")
	await wait_process_frames(2)
	var main = _main()
	assert_not_null(main.get("kites"), "main.kites")
	assert_lt(main.kites.get_index(), main.course_view.get_index(), "behind the course items")
