extends GutTest
# Task 247: the alien can be grabbed anywhere on it, not just at the pouch, which matters for the roguelike's big
# alien (90 px tall, most of it far above the pouch). The pull follows the hand from where it grabbed, and while
# dragging the alien sits in the pouch at its size.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_247_save.json"
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



func test_grab_anywhere_on_the_alien() -> void:
	var s = load("res://scripts/game/slingshot.gd").new()
	add_child_autofree(s)
	s.position = Vector2(200, 300)
	s.apply_stats(RogueSizes.apply(PlayerStats.new(), "big"), 0)
	assert_almost_eq(s.ball_radius_px, 0.75 * 2.5 * 1.5 * 16.0, 0.001, "the big alien's drawn radius")
	var top: Vector2 = s.global_position + Vector2(0, -80)
	assert_true(s.on_ball(top))
	assert_true(s.begin_drag(top), "grab the big alien near its top")
	s.update_drag(top + Vector2(-60, 40))
	assert_eq(s.pull, Vector2(-60, 40), "the pull follows the hand from where it grabbed")
	s.release()
	s.apply_stats(PlayerStats.new(), 0)
	assert_almost_eq(s.ball_radius_px, 18.0, 0.001, "the normal alien")
	assert_false(s.begin_drag(top), "nothing to grab up there")
	assert_true(s.begin_drag(s.global_position + Vector2(5, -30)), "the pouch still works")
	s.cancel_drag()


func test_big_alien_in_the_game() -> void:
	var main = _main()
	main.start_rogue(7)
	main.rogue.set_size("big")
	main._begin_aim()
	var center: Vector2 = main.projectile_view.global_position
	assert_almost_eq(center.y, main.slingshot.global_position.y - 45.0, 0.01, "the big alien rests right above the pouch")
	assert_true(main.slingshot.begin_drag(center + Vector2(0, -30)), "grabbed by its head")
	main.slingshot.update_drag(center + Vector2(-70, 10))
	main.advance(1.0 / 60.0)
	assert_eq(main.projectile_view.position, main.slingshot.pouch_position() + Vector2(0, -30), "sits in the pouch at its size")
	main.slingshot.release()
	assert_eq(main.state_name(), "FLIGHT", "and it launches")
