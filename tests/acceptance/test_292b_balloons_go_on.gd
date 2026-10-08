extends GutTest
# Task 292b: when the course grows, the next 2000 m get balloons too (with hats now and then); they pop like the first
# ones and the balloon view shows them.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_292b_save.json"
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



func test_balloons_go_on() -> void:
	var s = load("res://scripts/core/run_session.gd").new(PlayerStats.new(), 5)
	var before: int = s.balloons.points.size()
	s.extend_course()
	assert_gt(s.balloons.points.size(), before + 5, "balloons along the new 2000 m")
	assert_gt(s.balloons.points[before].x, 2000.0)
	assert_lt(s.balloons.points[s.balloons.points.size() - 1].x, 4000.0)
	assert_eq(s.balloons.used.size(), s.balloons.points.size())
	assert_eq(s.balloons.hats.size(), s.balloons.points.size())
	var again = load("res://scripts/core/run_session.gd").new(PlayerStats.new(), 5)
	again.extend_course()
	assert_eq(again.balloons.points, s.balloons.points, "the same seed grows the same balloons")
	assert_eq(again.balloons.hats, s.balloons.hats)
	var p: Vector2 = s.balloons.points[before]
	var sim := FlightSim.new()
	sim.position = p + Vector2(0.2, 0.0)
	s.balloons.after_step(sim, p - Vector2(0.2, 0.0))
	assert_true(s.balloons.used[before], "a new balloon pops")
	var main = _main()
	main.start_game()
	main.session.extend_course()
	assert_eq(main.balloon_view.points.size(), main.session.balloons.points.size(), "and the view shows the new ones")
