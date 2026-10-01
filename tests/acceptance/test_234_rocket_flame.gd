extends GutTest
# Task 234: while the rocket fires, a puff of flame comes out behind the alien every 0.06 s (not just once when it
# starts), and the shop and the Rocket perk describe the new rocket.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_234_save.json"
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



func test_flame_while_the_rocket_fires() -> void:
	var main = _main()
	main.progress.levels = {"boosts": 1}
	main.start_game()
	main.launch_with_pull(PULL)
	main.advance(1.0 / 60.0)
	var fb = main.feedback
	var before: int = main.effects.get_child_count()
	fb.tick_rocket(0.1)
	assert_eq(main.effects.get_child_count(), before, "no flame while the key is up")
	main.request_boost()
	var started: int = main.effects.get_child_count()
	for i in 10:
		fb.tick_rocket(0.03)
	assert_between(main.effects.get_child_count() - started, 4, 6, "a puff about every 0.06 s")
	main.session.release_boost()
	var after: int = main.effects.get_child_count()
	fb.tick_rocket(0.5)
	assert_eq(main.effects.get_child_count(), after, "the flame stops with the rocket")
	assert_true(str(UpgradeCatalog.get_def("boosts")["description"]).contains("0.5 s of rocket"))
	assert_true(str(RoguePerks.get_def("boost")["description"]).contains("0.5 s of rocket"))
