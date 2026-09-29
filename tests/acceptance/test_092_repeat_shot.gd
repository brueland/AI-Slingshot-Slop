extends GutTest
# Task 092: with the last-aim line unlocked, the R key repeats the last shot exactly, and the HUD says so.

const SLING := "res://scripts/game/slingshot.gd"
const HUD := "res://scripts/ui/hud.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_092_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _sling():
	var s = load(SLING).new()
	s.position = Vector2(0, -32)
	add_child_autofree(s)
	return s


func _key_r() -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = KEY_R
	e.pressed = true
	return e


func test_repeat_last_shot() -> void:
	var s = _sling()
	watch_signals(s)
	assert_false(s.repeat_last_shot(), "nothing to repeat yet")
	s.begin_drag(Vector2(0, -32))
	s.update_drag(Vector2(-70, 8))
	s.release()
	assert_false(s.repeat_last_shot(), "hidden aim line: no repeat")
	s.show_last_aim = true
	assert_true(s.repeat_last_shot())
	assert_signal_emitted_with_parameters(s, "launched", [Vector2(-70, 40)])
	assert_signal_emit_count(s, "launched", 2)
	s.enabled = false
	assert_false(s.repeat_last_shot(), "not while disabled")
	s.enabled = true
	s._unhandled_input(_key_r())
	assert_signal_emit_count(s, "launched", 3, "the R key repeats")


func test_hint_text() -> void:
	assert_eq(load(HUD).HINT_REPEAT, "Press R to repeat your last shot")


func test_repeat_in_the_game() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.progress.levels = {"guide": 1}
	main.progress.total_runs = 1
	main.start_game()
	assert_false(main.hud.hint_label.visible, "no hint before the first remembered shot")
	var anchor: Vector2 = main.slingshot.global_position
	main.slingshot.begin_drag(anchor)
	main.slingshot.update_drag(anchor + Vector2(-80, 60))
	main.slingshot.release()
	var first_velocity: Vector2 = main.session.sim.velocity
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.continue_to_shop()
	main.leave_shop()
	assert_true(main.hud.hint_label.visible)
	assert_eq(main.hud.hint_label.text, "Press R to repeat your last shot")
	main.slingshot._unhandled_input(_key_r())
	assert_eq(main.state_name(), "FLIGHT", "R launched the next shot")
	assert_eq(main.session.sim.velocity, first_velocity, "with exactly the same pull")
