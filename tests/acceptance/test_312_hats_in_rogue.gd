extends GutTest
# Task 312: the worn hat's boost counts in the roguelike too: a run keeps the hat it started with.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_312_save.json"
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


func _on_screen(main, control: Control, what: String) -> void:
	assert_true(main.get_viewport().get_visible_rect().encloses(control.get_global_rect()), what + " is on screen")



func test_hats_in_rogue() -> void:
	var plain = load("res://scripts/core/rogue_run.gd").new()
	plain.start(4)
	assert_eq(plain.get("hat"), "none")
	var run = load("res://scripts/core/rogue_run.gd").new()
	run.start(4, [], "wizard")
	assert_eq(run.hat, "wizard")
	assert_almost_eq(run.stats().drag, plain.stats().drag * 0.95, 0.0000001, "the Wizard Hat's -5% drag")
	var main = _main()
	main.progress.hat = "crown"
	main.start_rogue(9)
	assert_eq(main.rogue.hat, "crown", "a run starts with the worn hat")
	assert_almost_eq(main.session.stats.score_multiplier, main.rogue.stats().score_multiplier, 0.0001)
