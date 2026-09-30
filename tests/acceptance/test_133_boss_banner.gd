extends GutTest
# Task 133: during a roguelike boss round the HUD shows "BOSS ROUND!" at the top.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_133_save.json"


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


func test_boss_banner() -> void:
	var main = _main()
	main.start_rogue(13)
	assert_false(main.hud.boss_label.visible)
	main.rogue.round_number = 11
	main.rogue.goal = {"type": "distance", "target": 10.0, "round": 11, "text": "Fly at least 10 m"}
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.choose_rogue_perk(main.rogue.offer[0])
	assert_eq(main.rogue.goal["type"], "boss")
	assert_true(main.hud.boss_label.visible, "the boss banner is up")
	assert_eq(main.hud.boss_label.text, "BOSS ROUND!")
	await wait_process_frames(2)
	assert_true(main.get_viewport().get_visible_rect().encloses(main.hud.boss_label.get_global_rect()))
	main.go_to_title()
	main.start_game()
	assert_false(main.hud.boss_label.visible, "never in classic")
