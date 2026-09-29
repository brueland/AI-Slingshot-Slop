extends GutTest
# Task 041: scripts/game/audio_manager.gd plays the three music tracks (menu, flight, victory).

const PATH := "res://scripts/game/audio_manager.gd"


func _audio():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	var a = load(PATH).new()
	add_child_autofree(a)
	return a


func test_music_player_child() -> void:
	var a = _audio()
	if a == null:
		return
	assert_true(a is Node)
	assert_true(a.music_player is AudioStreamPlayer)
	if a.music_player is AudioStreamPlayer:
		assert_eq(a.music_player.get_parent(), a)
	assert_eq(a.current_music, "")


func test_play_music_tracks() -> void:
	var a = _audio()
	if a == null:
		return
	a.play_music("menu")
	assert_eq(a.current_music, "menu")
	assert_eq(a.music_player.stream.resource_path, "res://assets/audio/music/menu.ogg")
	assert_true(a.music_player.stream.loop, "menu music loops")
	a.play_music("flight")
	assert_eq(a.music_player.stream.resource_path, "res://assets/audio/music/flight.ogg")
	assert_true(a.music_player.stream.loop, "flight music loops")
	a.play_music("victory")
	assert_eq(a.current_music, "victory")
	assert_false(a.music_player.stream.loop, "the victory tune plays once")


func test_unknown_track_and_stop() -> void:
	var a = _audio()
	if a == null:
		return
	a.play_music("menu")
	a.play_music("disco")
	assert_eq(a.current_music, "menu", "unknown ids are ignored")
	a.stop_music()
	assert_eq(a.current_music, "")
