extends GutTest
# Checkpoint 33 (task 251c): with real frames, the view far past the course still has ground, markers and
# scenery under it, and the hills repeat without a seam.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_251c_save.json"
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



func test_far_flight_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.start_game()
	for x in [2300.0, 6000.0]:
		main.projectile_view.show_at(Vector2(x, 20.0))
		main.camera.snap_to(main.projectile_view.position)
		await wait_seconds(0.4)
		var wv = main.world_view
		var center: float = wv.view_center_m()
		assert_almost_eq(center, x, 40.0, "the view is out at %d m" % int(x))
		assert_lt(wv.drawn_from_m, center - 100.0, "ground behind")
		assert_gt(wv.drawn_to_m, center + 100.0, "ground ahead at %d m" % int(x))
		var near := 0
		for sprite in main.scenery.sprites:
			if absf(WorldView.screen_to_world(sprite.position).x - center) < 100.0:
				near += 1
		assert_gt(near, 2, "rocks and plants around %d m" % int(x))


func test_progress_log_records_milestone_33() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 32: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 33: complete"), "add the line 'Milestone 33: complete' to docs/PROGRESS.md")
