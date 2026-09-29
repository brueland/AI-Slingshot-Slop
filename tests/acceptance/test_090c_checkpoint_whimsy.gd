extends GutTest
# Checkpoint 9 (task 090c): the whimsy features work together with real frames: the first run unlocks the Party
# Hat (shown on the results), the Wardrobe puts it on (and it stays on after a restart), the hat rides upright on the rolling alien,
# bounces wobble it and wake the sheep, a new best throws confetti, and the alien has something to say.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_090c_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)
const NEW_SCRIPTS := {
	"res://scripts/game/projectile_decor.gd": "ProjectileDecor",
	"res://scripts/core/hats.gd": "Hats",
	"res://scripts/ui/wardrobe_panel.gd": "WardrobePanel",
	"res://scripts/game/critters.gd": "Critters",
	"res://scripts/core/quips.gd": "Quips",
}


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


func test_a_whimsical_first_session_with_real_frames() -> void:
	var main = _main()
	await wait_process_frames(2)
	main.title_panel.wardrobe_button.pressed.emit()
	assert_true(main.wardrobe_panel.hat_buttons["party"].disabled, "no Party Hat before the first run")
	main.wardrobe_panel.close_button.pressed.emit()
	main.title_panel.play_button.pressed.emit()
	var bounces := [0]
	main.session.sim.bounced.connect(func(_speed): bounces[0] += 1)
	var anchor: Vector2 = main.slingshot.global_position
	main.slingshot.begin_drag(anchor)
	main.slingshot.update_drag(anchor + FULL_PULL_45)
	await wait_process_frames(2)
	main.slingshot.release()
	var wobbled := false
	var upright := true
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
		if main.projectile_view.wobble_left > 0.0:
			wobbled = true
		if i % 60 == 0:
			await wait_process_frames(1)
			upright = upright and absf(main.projectile_view.decor.global_rotation) < 0.0001
	assert_gt(bounces[0], 0, "the shot bounced")
	assert_true(wobbled, "bounces wobble the alien")
	assert_true(upright, "the decor never rolls")
	assert_eq(main.state_name(), "RESULTS")
	assert_eq(main.projectile_view.decor.mood, "sleepy")
	assert_true(main.results_panel.hats_label.visible, "the results announce the Party Hat")
	var confetti := 0
	for c in main.effects.get_children():
		if c is CPUParticles2D and c.color_initial_ramp != null:
			confetti += 1
	assert_eq(confetti, 1, "a new best throws confetti")
	assert_true(main.results_panel.quip_label.text.begins_with("\""), "the alien says something")
	main.go_to_title()
	main.title_panel.wardrobe_button.pressed.emit()
	main.wardrobe_panel.hat_buttons["party"].pressed.emit()
	await wait_process_frames(2)
	assert_eq(main.projectile_view.decor.hat, "party")
	var again = _main()
	assert_eq(again.projectile_view.decor.hat, "party", "the hat stays on after a restart")


func test_sheep_wake_up_with_real_frames() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	var sheep = main.critters
	main.session.sim.position = Vector2(sheep.xs[2], 0.0)
	main.session.sim.bounced.emit(7.0)
	main.toggle_pause()
	await wait_seconds(0.25)
	assert_gt(sheep.hop_offset(2), 5.0, "the sheep is in the air")
	await wait_seconds(0.4)
	assert_eq(sheep.hop_offset(2), 0.0, "and lands again")


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


func test_progress_log_records_milestone_9() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 9: complete"), "add the line 'Milestone 9: complete' to docs/PROGRESS.md")
