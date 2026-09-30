extends GutTest
# Task 200: the HUD shows the alien's speed during a flight ("Speed: 23 m/s").

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_200_save.json"
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


func test_speed() -> void:
	var main = _main()
	main.start_game()
	var label = main.hud.speed_label
	assert_eq(label.text, "Speed: 0 m/s")
	assert_eq(label.get_index(), main.hud.boosts_label.get_index() + 1, "right under the boosts")
	main.launch_with_pull(PULL)
	for i in 10:
		main.advance(1.0 / 60.0)
	assert_eq(label.text, "Speed: %d m/s" % roundi(main.session.sim.velocity.length()))
	assert_gt(main.session.sim.velocity.length(), 5.0)
	await wait_process_frames(3)
	assert_true(main.get_viewport().get_visible_rect().encloses(label.get_global_rect()), "on screen")
