extends GutTest
# Checkpoint 6 (task 060c): the visual polish works together with real frames: themed UI, solid ground,
# scenery, trail, shadow, sky tint, and particle effects that clean themselves up.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_060c_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)
const NEW_SCRIPTS := {
	"res://scripts/ui/ui_theme.gd": "UiTheme",
	"res://scripts/game/trail.gd": "Trail",
	"res://scripts/game/ground_shadow.gd": "GroundShadow",
	"res://scripts/game/effects.gd": "Effects",
	"res://scripts/game/scenery.gd": "Scenery",
}


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_a_polished_flight_with_real_frames() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.progress.levels = {"power": 4, "bounce": 3}
	await wait_process_frames(2)
	main.title_panel.play_button.pressed.emit()
	var anchor: Vector2 = main.slingshot.global_position
	main.slingshot.begin_drag(anchor)
	main.slingshot.update_drag(anchor + FULL_PULL_45)
	await wait_process_frames(3)
	main.slingshot.release()
	var peak_trail := 0
	var spawned := 0
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
		peak_trail = maxi(peak_trail, main.trail.get_point_count())
		spawned = maxi(spawned, main.effects.get_child_count())
		if i % 120 == 0:
			await wait_process_frames(1)
	assert_eq(main.state_name(), "RESULTS")
	assert_eq(peak_trail, 30, "the trail filled up during the flight")
	assert_gt(spawned, 0, "bounces made dust")
	assert_gt(main.session.sim.bounce_count, 0)
	assert_almost_eq(main.shadow.position.x, main.session.sim.position.x * 16.0, 0.01)
	await wait_seconds(1.5)
	assert_eq(main.effects.get_child_count(), 0, "every particle effect freed itself after it finished")
	await wait_process_frames(2)
	for child in main.ui_layer.get_children():
		if child is Control:
			assert_eq(child.theme, main.ui_theme, "%s is themed" % child.name)


func test_world_layers_in_drawing_order() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var order := ["background", "world_view", "scenery", "course_view", "trail", "shadow", "projectile_view", "effects"]
	for i in range(1, order.size()):
		assert_lt(main.get(order[i - 1]).get_index(), main.get(order[i]).get_index(),
			"%s is drawn before %s" % [order[i - 1], order[i]])


func test_new_scripts_follow_the_conventions() -> void:
	for path in NEW_SCRIPTS:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + NEW_SCRIPTS[path]), "%s declares class_name %s" % [path, NEW_SCRIPTS[path]])
		assert_lt(text.split("\n").size(), 300, path + " stays under 300 lines")
		assert_false(text.contains("print("), path + " must not print")
	var main_text := FileAccess.get_file_as_string("res://scripts/game/main.gd")
	assert_lt(main_text.split("\n").size(), 450, "main.gd stays under 450 lines")


func test_progress_log_records_milestone_6() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 6: complete"), "add the line 'Milestone 6: complete' to docs/PROGRESS.md")
