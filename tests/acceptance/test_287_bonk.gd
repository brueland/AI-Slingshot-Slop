extends GutTest
# Task 287: hitting the brick wall says "Bonk!" (with a thud, a shake and an ouch face).

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_287_save.json"
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



func test_bonk() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(Vector2(84.85, 84.85))
	var popups: int = main.popups.get_child_count()
	main.session.sim.wall_hit.emit()
	assert_eq(main.popups.get_child_count(), popups + 1, "a Bonk! popup")
	assert_eq(main.audio.last_sfx, "bounce")
