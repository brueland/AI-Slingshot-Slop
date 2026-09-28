extends GutTest
# Task 021: scenes/main.tscn + scripts/game/main.gd, the game's state machine skeleton
# (docs/DESIGN.md sections 1, 8 and 9, main.gd).

const SCENE := "res://scenes/main.tscn"
const SCRIPT := "res://scripts/game/main.gd"
const SAVE := "user://test_021_save.json"


func _main():
	if not ResourceLoader.exists(SCENE) or not ResourceLoader.exists(SCRIPT):
		fail_test("missing " + SCENE + " or " + SCRIPT)
		return null
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_scene_is_a_single_node2d_with_main_script() -> void:
	if not ResourceLoader.exists(SCENE):
		fail_test("missing " + SCENE)
		return
	var main = load(SCENE).instantiate()
	assert_eq(main.name, "Main")
	assert_true(main is Node2D)
	assert_eq(main.get_script().resource_path, SCRIPT)
	assert_eq(main.get_child_count(), 0, "children are built in code in _ready(), not in the scene")
	main.free()


func test_state_enum() -> void:
	if not ResourceLoader.exists(SCRIPT):
		fail_test("missing " + SCRIPT)
		return
	var states: Dictionary = load(SCRIPT).State
	assert_eq(states.keys(), ["TITLE", "AIM", "FLIGHT", "RESULTS", "SHOP", "VICTORY"])


func test_starts_on_the_title_with_fresh_progress() -> void:
	var main = _main()
	if main == null:
		return
	assert_eq(main.state, 0)
	assert_eq(main.state_name(), "TITLE")
	assert_not_null(main.progress)
	assert_eq(main.save_path, SAVE)
	assert_false(main.is_paused)
	assert_eq(main.last_result, {})


func test_start_game_creates_a_session_and_aims() -> void:
	var main = _main()
	if main == null:
		return
	watch_signals(main)
	main.start_game()
	assert_eq(main.state_name(), "AIM")
	assert_signal_emitted_with_parameters(main, "state_changed", [1])
	assert_not_null(main.session)
	assert_false(main.session.launched)
	assert_eq(main.session.course, load("res://scripts/core/course_generator.gd").generate(1, 2000.0),
		"the first run's seed is total_runs + 1 = 1")
	var first = main.session
	main.start_game()
	assert_eq(main.session, first, "start_game only works on the title screen")


func test_change_state_emits_only_on_change() -> void:
	var main = _main()
	if main == null:
		return
	watch_signals(main)
	main.change_state(0)
	assert_signal_not_emitted(main, "state_changed")
	main.change_state(4)
	assert_eq(main.state_name(), "SHOP")
	assert_signal_emit_count(main, "state_changed", 1)
