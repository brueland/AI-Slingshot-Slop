extends GutTest
# Checkpoint 16 (task 144c): the meadow features work together with real frames: hills and kites behind the course,
# a bounce next to a cow grows a flower and moos, stars shoot high up, the title has a tip, and the results compare the
# run to the best.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_144c_save.json"
const NEW_SCRIPTS := {
	"res://scripts/game/hills.gd": "Hills",
	"res://scripts/game/flowers.gd": "Flowers",
	"res://scripts/game/cows.gd": "Cows",
	"res://scripts/game/kites.gd": "Kites",
	"res://scripts/core/tips.gd": "Tips",
}


func before_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func after_each() -> void:
	before_each()


func _fly(main) -> void:
	for i in 20000:
		if main.state_name() != "FLIGHT":
			return
		main.advance(1.0 / 60.0)


func test_meadow_with_real_frames() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	await wait_process_frames(2)
	assert_true(main.ui_layer.tip_label.visible, "a tip on the title")
	assert_true(main.background.hills_layer is Parallax2D)
	var kite: Vector2 = main.kites.kite_position(0)
	await wait_seconds(0.3)
	assert_ne(main.kites.kite_position(0), kite, "kites sway with real frames")
	main.start_game()
	main.launch_with_pull(Vector2(-84.852814, 84.852814))
	main.advance(1.0 / 60.0)
	main.session.sim.position = Vector2(main.cows.xs[0], 0.0)
	main.session.sim.bounced.emit(6.0)
	assert_true(main.flowers.xs.has(main.cows.xs[0]), "a flower where the alien bounced")
	var texts := []
	for p in main.popups.get_children():
		texts.append(p.text)
	assert_true(texts.has("Moo!"))
	main.toggle_pause()
	main.background.set_altitude(150.0)
	await wait_seconds(3.2)
	assert_gt(main.background.star_field.time, 3.0, "the night sky twinkles while the stars are out")
	main.toggle_pause()
	_fly(main)
	var best: float = main.progress.best_distance
	main.continue_to_shop()
	main.leave_shop()
	main.launch_with_pull(Vector2(-30, 20))
	_fly(main)
	await wait_process_frames(2)
	assert_true(main.results_panel.gap_label.text.ends_with("short of your best (%d m)" % roundi(best)))
	assert_true(main.get_viewport().get_visible_rect().encloses(main.results_panel.get_global_rect()))


func test_new_scripts_follow_the_conventions() -> void:
	for path in NEW_SCRIPTS:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + NEW_SCRIPTS[path]), path)
		assert_lt(text.split("\n").size(), 300)
		assert_false(text.contains("print("))
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_16() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 16: complete"), "add the line 'Milestone 16: complete' to docs/PROGRESS.md")
