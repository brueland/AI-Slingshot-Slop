extends GutTest
# Checkpoint 5 (task 050c, final): a bot plays the complete game through the real scene and its buttons, from
# an empty save to the 1000 m victory, and every asset, script and convention is checked.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_050c_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)
const DT := 1.0 / 30.0
const NAMED_SCRIPTS := {
	"res://scripts/game/audio_manager.gd": "AudioManager",
	"res://scripts/game/floating_text.gd": "FloatingText",
	"res://scripts/ui/options_panel.gd": "OptionsPanel",
	"res://scripts/ui/credits_panel.gd": "CreditsPanel",
}


func _remove() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func before_each() -> void:
	_remove()


func after_each() -> void:
	_remove()


func _buy_cheapest_with_buttons(main) -> void:
	var catalog = load("res://scripts/core/upgrade_catalog.gd")
	while true:
		var best_id := ""
		var best_cost := -1
		for id in catalog.ids():
			var c: int = main.progress.next_cost(id)
			if id != "guide" and c >= 0 and (best_cost < 0 or c < best_cost):
				best_id = id
				best_cost = c
		if best_id == "" or main.shop_panel.buttons[best_id].disabled:
			return
		main.shop_panel.buttons[best_id].pressed.emit()


func test_bot_plays_the_whole_game() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	await wait_process_frames(2)
	main.title_panel.play_button.pressed.emit()
	var runs := 0
	var musics := {}
	while runs < 90:
		var anchor: Vector2 = main.slingshot.global_position
		main.slingshot.begin_drag(anchor)
		main.slingshot.update_drag(anchor + FULL_PULL_45)
		main.advance(DT)
		main.slingshot.release()
		musics[main.audio.current_music] = true
		for i in 10000:
			if main.state_name() != "FLIGHT":
				break
			if main.session.sim.velocity.y < 0.0 and main.session.sim.position.y > 0.0:
				main._unhandled_input(_boost_event())
			main.advance(DT)
		runs += 1
		musics[main.audio.current_music] = true
		if main.state_name() == "VICTORY":
			break
		assert_eq(main.state_name(), "RESULTS", "run %d ends on the results screen" % runs)
		if main.state_name() != "RESULTS":
			return
		main.results_panel.continue_button.pressed.emit()
		_buy_cheapest_with_buttons(main)
		main.shop_panel.launch_button.pressed.emit()
	assert_eq(main.state_name(), "VICTORY", "the bot reaches 1000 m within 90 runs (best %.0f m)" % main.progress.best_distance)
	assert_between(runs, 12, 90, "runs to victory (design target about 35, took %d)" % runs)
	assert_true(musics.has("flight") and musics.has("victory"), "flight and victory music played")
	assert_gt(main.audio.sfx_played, runs * 2, "sound effects played during the game")
	await wait_process_frames(2)
	main.victory_panel.continue_button.pressed.emit()
	assert_eq(main.state_name(), "SHOP")
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_true(saved is Dictionary and bool(saved.get("goal_reached", false)), "the victory is saved")


func _boost_event() -> InputEventAction:
	var e := InputEventAction.new()
	e.action = "boost"
	e.pressed = true
	return e


func test_every_referenced_asset_exists() -> void:
	var paths := []
	paths.append_array(load("res://scripts/game/audio_manager.gd").MUSIC.values())
	paths.append_array(load("res://scripts/game/audio_manager.gd").SFX.values())
	paths.append_array(load("res://scripts/game/course_view.gd").TEXTURES.values())
	paths.append_array(load("res://scripts/game/projectile_view.gd").TEXTURES)
	for p in paths:
		assert_true(ResourceLoader.exists(p), "asset exists: " + p)


func test_all_scripts_follow_the_conventions() -> void:
	var scripts := []
	for dir in ["res://scripts/core", "res://scripts/game", "res://scripts/ui"]:
		var d := DirAccess.open(dir)
		if d == null:
			fail_test("missing folder " + dir)
			continue
		for f in d.get_files():
			if f.ends_with(".gd"):
				scripts.append(dir + "/" + f)
	assert_gt(scripts.size(), 25)
	for path in scripts:
		var text := FileAccess.get_file_as_string(path)
		var limit := 450 if path.ends_with("/main.gd") else 300
		assert_lt(text.split("\n").size(), limit, "%s must stay under %d lines" % [path, limit])
		assert_false(text.contains("print("), path + " must not print")
		assert_false(text.contains("get_tree().paused"), path + " must not pause the scene tree")
		if not path.ends_with("/main.gd"):
			assert_true(text.contains("class_name "), path + " declares a class_name")
	for path in NAMED_SCRIPTS:
		assert_true(FileAccess.get_file_as_string(path).contains("class_name " + NAMED_SCRIPTS[path]),
			"%s declares class_name %s" % [path, NAMED_SCRIPTS[path]])


func test_progress_log_records_milestone_5() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	for n in range(1, 6):
		assert_true(text.contains("Milestone %d: complete" % n), "docs/PROGRESS.md has 'Milestone %d: complete'" % n)
