extends GutTest
# Task 077: scripts/ui/rogue_panel.gd (after each roguelike shot: goal met or missed, the next goal, three perk
# buttons) and Hud.show_rogue (round, lives and goal during a roguelike shot).

const PATH := "res://scripts/ui/rogue_panel.gd"
const RUN := "res://scripts/core/rogue_run.gd"
const PERKS := "res://scripts/core/rogue_perks.gd"
const HUD := "res://scripts/ui/hud.gd"


func _panel():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	var p = load(PATH).new()
	add_child_autofree(p)
	return p


func test_shows_a_met_goal_and_three_perks() -> void:
	var p = _panel()
	if p == null:
		return
	assert_true(p is PanelContainer)
	assert_false(p.visible)
	assert_eq(p.perk_buttons.size(), 3)
	var run = load(RUN).new()
	run.start(7)
	var out: Dictionary = run.finish_shot({"distance": 45.0})
	p.show_outcome(out, run)
	assert_true(p.visible)
	assert_eq(p.title_label.text, "Goal met!")
	assert_eq(p.round_label.text, "Round 2 - Lives 3")
	assert_eq(p.goal_label.text, "Next goal: " + str(run.goal["text"]))
	for i in 3:
		var d: Dictionary = load(PERKS).get_def(run.offer[i])
		assert_eq(p.perk_buttons[i].text, "%s - %s" % [d["name"], d["description"]])
		assert_true(p.perk_buttons[i].visible)


func test_shows_a_miss() -> void:
	var p = _panel()
	if p == null:
		return
	var run = load(RUN).new()
	run.start(7)
	var out: Dictionary = run.finish_shot({"distance": 5.0})
	p.show_outcome(out, run)
	assert_eq(p.title_label.text, "Missed! Lives left: 2")
	assert_eq(p.round_label.text, "Round 1 - Lives 2")
	assert_eq(p.goal_label.text, "Next goal: Fly at least 40 m", "the same goal again")


func test_buttons_choose_perks() -> void:
	var p = _panel()
	if p == null:
		return
	watch_signals(p)
	var run = load(RUN).new()
	run.start(11)
	p.show_outcome(run.finish_shot({"distance": 45.0}), run)
	p.perk_buttons[2].pressed.emit()
	assert_signal_emitted_with_parameters(p, "perk_chosen", [run.offer[2]])


func test_panel_fits_on_screen() -> void:
	var p = _panel()
	if p == null:
		return
	var run = load(RUN).new()
	run.start(7)
	p.show_outcome(run.finish_shot({"distance": 45.0}), run)
	await wait_process_frames(3)
	var screen: Rect2 = p.get_viewport().get_visible_rect()
	var r: Rect2 = p.get_global_rect()
	assert_true(screen.encloses(r), "on screen: %s" % r)
	assert_lt((r.get_center() - screen.get_center()).length(), 4.0, "centered")


func test_hud_show_rogue() -> void:
	var h = load(HUD).new()
	add_child_autofree(h)
	h.show_rogue("Bounce 4 times", 5, 2)
	assert_eq(h.best_label.text, "Round 5")
	assert_eq(h.coins_label.text, "Lives: 2")
	assert_eq(h.goal_label.text, "Goal: Bounce 4 times")
