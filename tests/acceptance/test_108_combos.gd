extends GutTest
# Task 108: lively moments (a star, a spring, a balloon pop or a hard bounce) within 1.2 s of each other build a
# combo; from the third one a "Combo xN!" popup appears.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_108_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _main_in_flight():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	main.advance(1.0 / 60.0)
	return main


func _texts(main) -> Array:
	var texts := []
	for c in main.popups.get_children():
		texts.append(c.text)
	return texts


func test_combo_counting() -> void:
	var main = _main_in_flight()
	var fb = main.feedback
	assert_almost_eq(fb.COMBO_WINDOW, 1.2, 0.0001)
	assert_eq(fb.add_combo(), 1)
	fb.tick_combo(1.0)
	assert_eq(fb.add_combo(), 2, "within 1.2 s of the last one")
	fb.tick_combo(1.3)
	assert_eq(fb.combo, 0, "the combo ends after 1.2 s without a lively moment")
	assert_eq(fb.add_combo(), 1)


func test_events_build_a_combo_popup() -> void:
	var main = _main_in_flight()
	main.session.tracker.star_collected.emit(0)
	main.session.tracker.spring_hit.emit(0)
	assert_false(_texts(main).has("Combo x2!"), "no popup for two")
	main.session.sim.bounced.emit(9.0)
	assert_eq(main.feedback.combo, 3)
	assert_true(_texts(main).has("Combo x3!"), "popups: %s" % [_texts(main)])
	main.session.balloons.popped.emit(0)
	assert_true(_texts(main).has("Combo x4!"))
	main.session.sim.bounced.emit(3.0)
	assert_eq(main.feedback.combo, 4, "a soft bounce is not lively")


func test_a_new_shot_starts_without_a_combo() -> void:
	var main = _main_in_flight()
	main.feedback.add_combo()
	main.feedback.add_combo()
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	main.continue_to_shop()
	main.leave_shop()
	assert_eq(main.feedback.combo, 0)
