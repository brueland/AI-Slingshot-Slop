extends GutTest
# Task 042: AudioManager also plays sound effects on a pool of 6 AudioStreamPlayers, round robin.

const PATH := "res://scripts/game/audio_manager.gd"


func _audio():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	var a = load(PATH).new()
	add_child_autofree(a)
	return a


func test_six_voices() -> void:
	var a = _audio()
	if a == null:
		return
	assert_eq(a.sfx_players.size(), 6)
	for p in a.sfx_players:
		assert_true(p is AudioStreamPlayer and p.get_parent() == a)


func test_play_sfx() -> void:
	var a = _audio()
	if a == null:
		return
	assert_true(a.play_sfx("bounce"))
	assert_eq(a.last_sfx, "bounce")
	assert_eq(a.sfx_played, 1)
	assert_eq(a.sfx_players[0].stream.resource_path, "res://assets/audio/sfx/bounce.mp3")
	assert_false(a.play_sfx("kazoo"), "unknown ids play nothing")
	assert_eq(a.sfx_played, 1)
	assert_eq(a.last_sfx, "bounce")


func test_every_effect_exists_and_voices_rotate() -> void:
	var a = _audio()
	if a == null:
		return
	var ids := ["launch", "bounce", "star", "spring", "boost", "buy", "milestone", "click"]
	for id in ids:
		assert_true(a.play_sfx(id), "sound effect " + id)
	assert_eq(a.sfx_played, 8)
	# 8 plays on 6 voices: the 7th and 8th reuse voices 0 and 1
	assert_eq(a.sfx_players[0].stream.resource_path, "res://assets/audio/sfx/milestone.mp3")
	assert_eq(a.sfx_players[1].stream.resource_path, "res://assets/audio/sfx/click.wav")
	assert_eq(a.sfx_players[2].stream.resource_path, "res://assets/audio/sfx/star.mp3")
