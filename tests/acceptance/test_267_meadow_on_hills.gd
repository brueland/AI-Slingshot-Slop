extends GutTest
# Task 267: the sheep, the flowers and the kites' strings stand on the hills too.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_267_save.json"
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



func test_meadow_on_hills() -> void:
	var main = _main()
	main.start_rogue(5)
	main.rogue.round_number = 20
	main._begin_aim()
	var x: float = main.critters.xs[0]
	assert_almost_eq(main.critters.sheep_position(0).y + main.critters.hop_offset(0), WorldView.ground_point(x).y, 0.01, "sheep stand on the hill")
	var k: float = main.kites.ANCHORS_M[0]
	var lift: Vector2 = main.kites.kite_position(0) - WorldView.ground_point(k)
	assert_lt(lift.y, -150.0, "a kite flies high over its anchor on the hill")
	var text := FileAccess.get_file_as_string("res://scripts/game/flowers.gd")
	assert_true(text.contains("WorldView.ground_point(xs[i])"), "flowers grow on the ground")
	main.flowers.grow_at(300.0)
	await wait_process_frames(2)
	assert_eq(main.flowers.seen_terrain, WorldView.terrain_version)
