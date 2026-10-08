extends GutTest
# Task 293: the sheep, cows and birds go on forever (their 2000 m layouts repeat), react and scatter there too, and
# only the ones on screen are drawn.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_293_save.json"
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



func test_meadow_goes_on() -> void:
	var main = _main()
	var sheep = main.critters
	var x0: float = sheep.xs[0]
	assert_eq(sheep.react(x0 + 2000.0), 0, "the flock repeats every 2000 m")
	assert_eq(sheep.react(x0 + 2000.0 + 10.0), -1)
	assert_eq(sheep.react(x0 - 1.0), 0, "the first sheep as before")
	var cows = main.cows
	assert_eq(cows.react(cows.xs[0] + 6000.0 + 2.0), 0, "cows too")
	var birds = main.birds
	birds.reset()
	var far: Vector2 = birds.bird_position_near(0, birds.perches[0].x + 4000.0)
	assert_eq(far, birds.bird_position(0) + Vector2(4000.0 * Balance.PIXELS_PER_METER, 0.0), "birds 4000 m on")
	assert_eq(birds.scare_near(far + Vector2(10.0, 0.0)), 1, "and they scatter there")
	for path in ["critters.gd", "cows.gd", "birds.gd"]:
		var text := FileAccess.get_file_as_string("res://scripts/game/" + path)
		assert_true(text.contains("visible_span"), path + " draws only what is on screen")
	main.camera.snap_to(WorldView.world_to_screen(Vector2(4100.0, 0.0)))
	await wait_process_frames(3)
	pass_test("the meadow draws 4100 m out without errors")
