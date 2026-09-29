extends GutTest
# Task 089: confetti and a big popup for great moments: "NEW BEST!", "Milestone!" or a roguelike "Goal!".

const EFFECTS := "res://scripts/game/effects.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_089_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func _fly(main) -> void:
	for i in 20000:
		if main.state_name() != "FLIGHT":
			return
		main.advance(1.0 / 60.0)


func _confetti_count(main) -> int:
	var n := 0
	for c in main.effects.get_children():
		if c is CPUParticles2D and c.color_initial_ramp != null:
			n += 1
	return n


func _popup_texts(main) -> Array:
	var texts := []
	for c in main.popups.get_children():
		texts.append(c.text)
	return texts


func test_spawn_confetti() -> void:
	var e = load(EFFECTS).new()
	add_child_autofree(e)
	var p = e.spawn_confetti(Vector2(100, 100))
	assert_true(p is CPUParticles2D)
	assert_eq(p.get_parent(), e)
	assert_eq(p.amount, 60)
	assert_true(p.one_shot)
	assert_not_null(p.color_initial_ramp, "many colors")
	assert_gt(p.gravity.y, 0.0, "it flutters down")
	await wait_seconds(2.5)
	assert_false(is_instance_valid(p), "frees itself when done")


func test_celebrate() -> void:
	var main = _main()
	main.start_game()
	var fb = main.feedback
	assert_eq(fb.celebrate({}), "", "nothing to celebrate")
	assert_eq(_confetti_count(main), 0)
	assert_eq(fb.celebrate({"new_best": true, "milestones": [{"name": "x"}]}), "NEW BEST!")
	assert_eq(fb.celebrate({"new_best": false, "milestones": [{"name": "x"}]}), "Milestone!")
	assert_eq(fb.celebrate({"goal_met": true}), "Goal!")
	assert_eq(_confetti_count(main), 3)
	assert_true(_popup_texts(main).has("NEW BEST!"))


func test_a_new_best_throws_confetti() -> void:
	var main = _main()
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	_fly(main)
	assert_true(main.last_result["new_best"])
	assert_eq(_confetti_count(main), 1)
	assert_true(_popup_texts(main).has("NEW BEST!"))


func test_a_roguelike_goal_throws_confetti() -> void:
	var main = _main()
	main.start_rogue(7)
	main.launch_with_pull(FULL_PULL_45)
	_fly(main)
	assert_true(main.rogue_outcome["met"])
	assert_eq(_confetti_count(main), 1)
	assert_true(_popup_texts(main).has("Goal!"))
