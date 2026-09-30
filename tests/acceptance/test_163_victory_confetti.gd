extends GutTest
# Task 163: the victory screen rains confetti.


func test_victory_confetti() -> void:
	var v = load("res://scripts/ui/victory_panel.gd").new()
	add_child_autofree(v)
	assert_true(v.get("confetti") is CPUParticles2D, "victory_panel.confetti")
	if not v.get("confetti") is CPUParticles2D:
		return
	assert_false(v.confetti.emitting)
	v.show_victory(12)
	assert_true(v.confetti.emitting, "confetti on the victory screen")
	assert_eq(v.message_label.text, "You reached 1000 m in 12 runs!")
	await wait_process_frames(3)
	pass_test("draws without errors")
