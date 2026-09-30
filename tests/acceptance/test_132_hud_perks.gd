extends GutTest
# Task 132: the roguelike HUD lists the perks taken so far ("Perks: Stronger Bands x2, Rocket"); classic hides it.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_132_save.json"


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


func test_summary() -> void:
	var perks = load("res://scripts/core/rogue_perks.gd")
	assert_eq(perks.summary([]), "")
	assert_eq(perks.summary(["power", "boost", "power"]), "Stronger Bands x2, Rocket")
	assert_eq(perks.summary(["steady"]), "Steady Hand")


func test_hud_perks() -> void:
	var main = _main()
	main.start_rogue(7)
	assert_false(main.hud.perks_label.visible, "no perks yet")
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.rogue.offer.assign(["power", "aero", "boost"])
	main.choose_rogue_perk("power")
	assert_true(main.hud.perks_label.visible)
	assert_eq(main.hud.perks_label.text, "Perks: Stronger Bands")
	main.go_to_title()
	main.start_game()
	assert_false(main.hud.perks_label.visible, "classic has no perks")
