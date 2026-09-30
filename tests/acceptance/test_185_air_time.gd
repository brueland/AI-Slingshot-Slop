extends GutTest
# Task 185: FlightSim.air_time counts the seconds spent in the air; the run result has it as "air_time".

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_185_save.json"
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


func test_air_time() -> void:
	var sim = load("res://scripts/core/flight_sim.gd").new()
	sim.air_time = 9.0
	sim.launch(Vector2(0, 1), Vector2(10, 30))
	assert_eq(sim.air_time, 0.0, "a launch starts over")
	for i in 60:
		sim.step(1.0 / 60.0)
	assert_true(sim.is_airborne())
	assert_almost_eq(sim.air_time, 1.0, 0.0001, "one second in the air")
	var steps: int = sim.simulate(1.0 / 60.0, 100000)
	assert_true(sim.stopped)
	assert_gt(sim.air_time, 1.5)
	assert_lt(sim.air_time, 1.0 + steps / 60.0 + 0.0001, "the slide does not count")
	var main = _main()
	main.start_game()
	_fly(main, PULL)
	assert_gt(float(main.last_result.get("air_time", 0.0)), 1.0, "the result has the air time")
	assert_eq(main.last_result["air_time"], main.session.sim.air_time)
