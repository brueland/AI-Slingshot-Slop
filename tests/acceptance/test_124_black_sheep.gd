extends GutTest
# Task 124: some sheep are black (index 2, 6, 10, ...) and say "Meh." instead of "Baa!".

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_124_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _main_in_flight():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	return main


func _texts(main) -> Array:
	var texts := []
	for c in main.popups.get_children():
		texts.append(c.text)
	return texts


func test_black_sheep() -> void:
	var c = load("res://scripts/game/critters.gd")
	assert_true(c.is_black(2))
	assert_true(c.is_black(6))
	assert_false(c.is_black(0))
	assert_false(c.is_black(3))
	var main = _main_in_flight()
	var sheep = main.critters
	main.session.sim.position = Vector2(sheep.xs[2], 0.0)
	main.session.sim.bounced.emit(5.0)
	assert_true(_texts(main).has("Meh."), "a black sheep is grumpy")
	main.session.sim.position = Vector2(sheep.xs[0], 0.0)
	main.session.sim.bounced.emit(5.0)
	assert_true(_texts(main).has("Baa!"), "a white sheep says Baa!")
	await wait_process_frames(2)
	pass_test("the flock draws without errors")
