extends GutTest
# Task 107: bounce, star and spring sounds play at a slightly random pitch (0.88-1.12) so repeats don't sound
# robotic; every other sound plays at its normal pitch.

const PATH := "res://scripts/game/audio_manager.gd"


func test_pitch_variety() -> void:
	var consts: Dictionary = load(PATH).get_script_constant_map()
	assert_eq(consts.get("PITCH_VARIED"), ["bounce", "star", "spring"])
	var a = load(PATH).new()
	add_child_autofree(a)
	assert_almost_eq(float(a.get("last_pitch")), 1.0, 0.0001)
	var seen := {}
	for i in 20:
		assert_true(a.play_sfx("bounce"))
		assert_between(a.last_pitch, 0.88, 1.12)
		seen[snappedf(a.last_pitch, 0.001)] = true
		var voice: AudioStreamPlayer = a.sfx_players[(a._next_voice + a.SFX_VOICES - 1) % a.SFX_VOICES]
		assert_almost_eq(voice.pitch_scale, a.last_pitch, 0.0001, "the voice plays at that pitch")
	assert_gt(seen.size(), 5, "the pitch changes from bounce to bounce")
	a.play_sfx("buy")
	assert_almost_eq(a.last_pitch, 1.0, 0.0001, "other sounds keep their pitch")
	var voice: AudioStreamPlayer = a.sfx_players[(a._next_voice + a.SFX_VOICES - 1) % a.SFX_VOICES]
	assert_almost_eq(voice.pitch_scale, 1.0, 0.0001)
