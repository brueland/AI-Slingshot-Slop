extends GutTest
# Task 236: a roguelike shot with a landing zone (or a boss part that is one) has the zone's dip in its physics, the
# zone marker draws the dip, and the alien's shadow sits on the dip's floor.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_236_save.json"
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



func test_dip_on_the_field() -> void:
	var main = _main()
	main.start_rogue(5)
	main.rogue.goal = {"type": "zone", "target": 40.0, "round": 3, "text": "Stop between 40 and 60 m"}
	main._begin_aim()
	assert_eq(main.session.sim.dips, [Vector2(40, 60)], "the zone's dip is in the shot's physics")
	main.rogue.goal = {"type": "height", "target": 9.0, "round": 3, "text": "Reach 9 m high"}
	main._begin_aim()
	assert_eq(main.session.sim.dips, [], "no zone, flat ground")
	var outline = load("res://scripts/game/zone_marker.gd").dip_outline(Vector2(40, 60))
	assert_eq(outline.size(), 4)
	assert_eq(outline[0], WorldView.world_to_screen(Vector2(38.5, 0.0)))
	assert_eq(outline[1], WorldView.world_to_screen(Vector2(40.0, -0.75)))
	assert_eq(outline[2], WorldView.world_to_screen(Vector2(60.0, -0.75)))
	assert_eq(outline[3], WorldView.world_to_screen(Vector2(61.5, 0.0)))
	main.shadow.update_from(Vector2(50.0, -0.75), -0.75)
	assert_eq(main.shadow.position, WorldView.world_to_screen(Vector2(50.0, -0.75)), "the shadow is on the floor")
	assert_almost_eq(main.shadow.shadow_scale, 1.0, 0.0001, "full size when resting")


func test_classic_has_no_dips() -> void:
	var main = _main()
	main.start_game()
	assert_eq(main.session.sim.dips, [])
