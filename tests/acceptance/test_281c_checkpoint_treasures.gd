extends GutTest
# Checkpoint 39 (task 281c): with real frames, popping a hat balloon finds its hat for the Wardrobe (kept after the
# shot and saved), and a special perk found in a run is offered from then on.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_281c_save.json"
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



func test_treasures_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.start_game()
	var b = main.session.balloons
	var i: int = b.hats.find("viking")
	if i == -1:
		i = 0
		b.hats[0] = "viking"
	main.launch_with_pull(PULL)
	await wait_seconds(0.2)
	main.session.sim.position = b.points[i] - Vector2(0.0, main.session.stats.pickup_offset)
	main.session.sim.velocity = Vector2(1.0, 0.0)
	await wait_physics_frames(2)
	assert_true(b.found_hats.has("viking"), "the balloon popped and its hat was found")
	for k in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	assert_true(Hats.is_unlocked("viking", main.progress), "the Viking Helmet is in the Wardrobe")
	var saved := SaveSystem.load_progress(SAVE)
	assert_true(saved.found.has("viking"), "and saved")


func test_progress_log_records_milestone_39() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 38: complete"), "the earlier lines are kept")
	assert_true(text.contains("Milestone 39: complete"), "add the line 'Milestone 39: complete' to docs/PROGRESS.md")
