extends GutTest
# Task 045: music and sound-effect volumes are saved in Progress.settings and applied by AudioManager.

const PROGRESS := "res://scripts/core/progress.gd"
const AUDIO := "res://scripts/game/audio_manager.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_045_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_progress_settings_round_trip() -> void:
	var script = load(PROGRESS)
	var p = script.new()
	assert_eq(p.settings, {"music_volume": 0.8, "sfx_volume": 0.8})
	p.settings["music_volume"] = 0.3
	var d: Dictionary = p.to_dict()
	assert_true(d.has("settings"), "to_dict() includes settings")
	var q = script.from_dict(JSON.parse_string(JSON.stringify(d)))
	assert_almost_eq(float(q.settings.get("music_volume", -1.0)), 0.3, 0.0001)
	assert_almost_eq(float(q.settings.get("sfx_volume", -1.0)), 0.8, 0.0001)


func test_old_or_bad_settings_are_repaired() -> void:
	var script = load(PROGRESS)
	var old = script.from_dict({"coins": 5})
	assert_eq(old.settings, {"music_volume": 0.8, "sfx_volume": 0.8}, "old saves without settings get defaults")
	var bad = script.from_dict({"settings": {"music_volume": 1.5, "sfx_volume": -1.0}})
	assert_almost_eq(float(bad.settings["music_volume"]), 1.0, 0.0001)
	assert_almost_eq(float(bad.settings["sfx_volume"]), 0.0, 0.0001)
	var a = script.new()
	var b = script.new()
	a.settings["music_volume"] = 0.1
	assert_almost_eq(float(b.settings["music_volume"]), 0.8, 0.0001, "each Progress has its own settings")


func test_audio_volumes() -> void:
	if not ResourceLoader.exists(AUDIO):
		fail_test("missing " + AUDIO)
		return
	var am = load(AUDIO)
	assert_almost_eq(am.volume_to_db(1.0), 0.0, 0.001)
	assert_almost_eq(am.volume_to_db(0.5), -6.0206, 0.001)
	assert_almost_eq(am.volume_to_db(0.0), -80.0, 0.001, "0 is silent")
	var a = am.new()
	add_child_autofree(a)
	a.set_music_volume(0.5)
	assert_almost_eq(a.music_volume, 0.5, 0.0001)
	assert_almost_eq(a.music_player.volume_db, -6.0206, 0.001)
	a.set_sfx_volume(0.0)
	for p in a.sfx_players:
		assert_almost_eq(p.volume_db, -80.0, 0.001)
	a.set_music_volume(3.0)
	assert_almost_eq(a.music_volume, 1.0, 0.0001, "clamped to 0..1")


func test_main_applies_saved_volumes() -> void:
	var f := FileAccess.open(SAVE, FileAccess.WRITE)
	f.store_string(JSON.stringify({"settings": {"music_volume": 0.25, "sfx_volume": 0.5}}))
	f.close()
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	assert_almost_eq(main.audio.music_volume, 0.25, 0.0001)
	assert_almost_eq(main.audio.sfx_volume, 0.5, 0.0001)
	assert_almost_eq(main.audio.music_player.volume_db, linear_to_db(0.25), 0.001)
