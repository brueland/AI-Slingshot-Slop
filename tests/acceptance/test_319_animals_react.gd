extends GutTest
# Task 319: a sheep the alien bounces off hops and says "Boing!"; a cow that kicks it says "Moo! Kick!".

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_319_save.json"
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



func test_animals_react() -> void:
	var main = _main()
	main.start_game()
	assert_true(main.feedback.watchers.has(main.critters), "the sheep follow every shot")
	assert_true(main.feedback.watchers.has(main.cows), "the cows too")
	var x: float = main.critters.xs[0]
	main.session.animals.sheep_hit.emit(x)
	assert_gt(main.critters.hop_left[0], 0.0, "the sheep hops")
	assert_eq(main.critters.get_child(main.critters.get_child_count() - 1).text, "Boing!")
	main.session.animals.cow_hit.emit(main.cows.xs[0])
	assert_eq(main.cows.get_child(main.cows.get_child_count() - 1).text, "Moo! Kick!")
	main.go_to_title()
	main.start_game()
	assert_true(main.session.animals.sheep_hit.is_connected(main.critters._on_sheep_hit), "and the next shot")
