extends GutTest
# Task 097: the roguelike perk offer can be rerolled: one reroll per run, plus one for every 5 rounds cleared.
# The perk panel has a "Reroll perks (N left)" button.

const RUN := "res://scripts/core/rogue_run.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_097_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_rerolls_in_a_run() -> void:
	var r = load(RUN).new()
	r.start(7)
	assert_eq(r.get("rerolls"), 1)
	assert_false(r.reroll(), "nothing to reroll before a shot")
	assert_eq(r.rerolls, 1)
	r.finish_shot({"distance": 45.0})
	var first: Array = r.offer.duplicate()
	assert_true(r.reroll())
	assert_eq(r.rerolls, 0)
	assert_eq(r.offer.size(), 3)
	assert_ne(r.offer, first, "a different offer")
	var unique := {}
	for id in r.offer:
		unique[id] = true
	assert_eq(unique.size(), 3)
	assert_false(r.reroll(), "no rerolls left")
	assert_true(r.choose_perk(r.offer[0]), "a rerolled perk can be taken")
	r.rounds_cleared = 4
	r.goal = {"type": "distance", "target": 10.0, "round": 5, "text": "Fly at least 10 m"}
	r.finish_shot({"distance": 50.0})
	assert_eq(r.rounds_cleared, 5)
	assert_eq(r.rerolls, 1, "5 rounds cleared earn a reroll")
	r.start(9)
	assert_eq(r.rerolls, 1, "a new run starts with one")


func test_no_reroll_after_the_run() -> void:
	var r = load(RUN).new()
	r.start(7)
	r.lives = 1
	r.finish_shot({"distance": 5.0})
	assert_true(r.is_over())
	assert_false(r.reroll())


func test_reroll_button() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	main.start_rogue(7)
	main.launch_with_pull(FULL_PULL_45)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	var panel = main.ui_layer.rogue_panel
	assert_true(panel.get("reroll_button") is Button, "rogue_panel.reroll_button")
	assert_eq(panel.reroll_button.text, "Reroll perks (1 left)")
	assert_false(panel.reroll_button.disabled)
	var before: Array = main.rogue.offer.duplicate()
	panel.reroll_button.pressed.emit()
	assert_ne(main.rogue.offer, before)
	assert_eq(panel.reroll_button.text, "Reroll perks (0 left)")
	assert_true(panel.reroll_button.disabled)
	var d: Dictionary = load("res://scripts/core/rogue_perks.gd").get_def(main.rogue.offer[0])
	assert_eq(panel.perk_buttons[0].text, "%s - %s" % [d["name"], d["description"]], "the buttons show the new offer")
	assert_eq(main.state_name(), "RESULTS", "still choosing")
	assert_false(main.reroll_perks(), "no rerolls left")
	await wait_process_frames(2)
	assert_true(main.get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "panel still fits on screen")
