extends GutTest
# Task 135: the title shows "Roguelike best: N rounds" once a roguelike run has cleared a round.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_135_save.json"


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


func test_title_rogue_best() -> void:
	var main = _main()
	var label = main.title_panel.get("rogue_best_label")
	assert_true(label is Label, "title_panel.rogue_best_label")
	if not label is Label:
		return
	assert_false(label.visible, "hidden before any roguelike round")
	_lose_a_run(main, 9, 6)
	main.go_to_title()
	assert_true(label.visible)
	assert_eq(label.text, "Roguelike best: 6 rounds")
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(main.title_panel.get_global_rect()), "the title still fits")
