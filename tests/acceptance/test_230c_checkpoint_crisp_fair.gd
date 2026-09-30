extends GutTest
# Checkpoint 29 (task 230c): with real frames, a big roguelike alien with a zone goal shows the landing zone on the
# field, is drawn sharp from its big texture, and picks up stars with its drawn body.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_230c_save.json"
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



func test_crisp_and_fair_with_real_frames() -> void:
	var main = _main()
	main.start_rogue(5)
	main.rogue.set_size("big")
	main.rogue.goal = {"type": "zone", "target": 30.0, "round": 3, "text": "Stop between 30 and 50 m"}
	main._begin_aim()
	await wait_seconds(0.3)
	assert_true(main.zone_marker.visible)
	assert_almost_eq(main.projectile_view.texture.get_width() * main.projectile_view.scale.x, 90.0, 0.01)
	assert_almost_eq(main.session.stats.pickup_radius, 0.75 * 2.5 * 1.5 + 0.9, 0.0001, "the big alien's drawn body")
	main.launch_with_pull(PULL)
	await wait_seconds(0.4)
	assert_eq(main.state_name(), "FLIGHT")


func test_new_code_follows_the_conventions() -> void:
	var text := FileAccess.get_file_as_string("res://scripts/game/zone_marker.gd")
	assert_true(text.contains("class_name ZoneMarker"))
	assert_false(text.contains("print("))
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_29() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 29: complete"), "add the line 'Milestone 29: complete' to docs/PROGRESS.md")
