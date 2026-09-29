extends GutTest
# Task 043: main.gd owns an AudioManager (main.audio) and plays menu music on the title/results/shop,
# flight music while aiming and flying, and the victory tune on the victory screen.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_043_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _main():
	if not ResourceLoader.exists(SCENE):
		fail_test("missing " + SCENE)
		return null
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func _fly(main) -> void:
	for i in 30000:
		if main.state_name() != "FLIGHT":
			return
		if main.session.sim.velocity.y < 0.0:
			main.request_boost()
		main.advance(1.0 / 60.0)


func test_audio_manager_child() -> void:
	var main = _main()
	if main == null:
		return
	var audio = main.get("audio")
	assert_not_null(audio, "main.audio")
	if audio != null:
		assert_eq(audio.get_script().resource_path, "res://scripts/game/audio_manager.gd")
		assert_eq(audio.get_parent(), main)


func test_music_follows_the_state() -> void:
	var main = _main()
	if main == null or main.get("audio") == null:
		fail_test("main.audio missing")
		return
	assert_eq(main.audio.current_music, "menu", "title screen")
	main.start_game()
	assert_eq(main.audio.current_music, "flight", "aiming")
	main.launch_with_pull(FULL_PULL_45)
	assert_eq(main.audio.current_music, "flight", "flying")
	_fly(main)
	assert_eq(main.audio.current_music, "menu", "results")
	main.continue_to_shop()
	assert_eq(main.audio.current_music, "menu", "shop")


func test_victory_music() -> void:
	var main = _main()
	if main == null or main.get("audio") == null:
		fail_test("main.audio missing")
		return
	var levels := {}
	for id in load("res://scripts/core/upgrade_catalog.gd").ids():
		levels[id] = 99
	main.progress.levels = levels
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	_fly(main)
	assert_eq(main.state_name(), "VICTORY")
	assert_eq(main.audio.current_music, "victory")
