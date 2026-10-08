extends GutTest
# Task 289: the top-left HUD box keeps its width while the distance, height and speed numbers change, so it no longer
# jitters wider and narrower during a fast flight.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_289_save.json"
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



func test_steady_hud_box() -> void:
	var main = _main()
	main.start_game()
	var hud = main.hud
	hud.update_flight(5.0, 1.0, 0, 0.0, 0.0)
	await wait_process_frames(3)
	var bar_x: float = hud.altitude_bar.global_position.x
	var width: float = hud.distance_label.get_parent().size.x
	assert_gte(width, float(hud.get("LEFT_TEXT_WIDTH")), "the column is LEFT_TEXT_WIDTH wide")
	for v in [[24000.0, 456.0, 88, 3.5, 4.0], [7.0, 0.0, 1, 0.0, 0.0], [88888.0, 8888.0, 888, 88.8, 99.0]]:
		hud.update_flight(v[0], v[1], v[2], v[3], v[4])
		await wait_process_frames(2)
		assert_eq(hud.distance_label.get_parent().size.x, width, "same width for " + hud.distance_label.text)
		assert_eq(hud.altitude_bar.global_position.x, bar_x, "the height bar stays put")
