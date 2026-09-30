extends GutTest
# Task 131: the run-over screen lists the last runs ("Last runs: 4, 2 rounds") and "Play this seed again" starts a
# new run with the same seed.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_131_save.json"


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


func _lose_a_run(main, run_seed: int, rounds: int) -> void:
	main.start_rogue(run_seed)
	main.rogue.rounds_cleared = rounds
	main.rogue.lives = 1
	main.launch_with_pull(Vector2(-12, 0))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_history_and_replay() -> void:
	var main = _main()
	_lose_a_run(main, 55, 2)
	main.go_to_title()
	_lose_a_run(main, 77, 4)
	var over = main.ui_layer.rogue_over_panel
	assert_true(over.visible)
	assert_eq(over.history_label.text, "Last runs: 4, 2 rounds")
	assert_eq(over.replay_button.text, "Play this seed again")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(over.get_global_rect()), "the panel fits on screen")
	over.replay_button.pressed.emit()
	assert_eq(main.state_name(), "AIM")
	assert_eq(main.mode, "rogue")
	assert_eq(main.rogue.run_seed, 77, "the same seed again")
	assert_eq(main.rogue.round_number, 1)
	assert_false(over.visible)
