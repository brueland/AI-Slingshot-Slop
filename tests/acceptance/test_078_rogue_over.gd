extends GutTest
# Task 078: scripts/ui/rogue_over_panel.gd (run over: rounds cleared, best, perks taken, Back to title) and
# Progress.best_rogue_round, saved with the rest of the progress.

const PATH := "res://scripts/ui/rogue_over_panel.gd"
const RUN := "res://scripts/core/rogue_run.gd"
const PROGRESS := "res://scripts/core/progress.gd"


func test_over_panel() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var p = load(PATH).new()
	add_child_autofree(p)
	watch_signals(p)
	assert_true(p is PanelContainer)
	assert_false(p.visible)
	assert_eq(p.title_label.text, "Run over")
	assert_eq(p.back_button.text, "Back to title")
	var run = load(RUN).new()
	run.start(7)
	run.finish_shot({"distance": 45.0})
	run.perks.assign(["power", "steady", "power"])
	run.rounds_cleared = 4
	p.show_over(run, 6)
	assert_true(p.visible)
	assert_eq(p.rounds_label.text, "Rounds cleared: 4")
	assert_eq(p.best_label.text, "Best: 6 rounds")
	assert_eq(p.perks_label.text, "Perks: Stronger Bands, Steady Hand, Stronger Bands")
	run.perks.clear()
	p.show_over(run, 6)
	assert_eq(p.perks_label.text, "Perks: none")
	p.back_button.pressed.emit()
	assert_signal_emitted(p, "back_pressed")
	await wait_process_frames(2)
	var screen: Rect2 = p.get_viewport().get_visible_rect()
	assert_true(screen.encloses(p.get_global_rect()), "on screen")


func test_best_rogue_round_is_saved() -> void:
	var script = load(PROGRESS)
	var p = script.new()
	assert_eq(p.get("best_rogue_round"), 0)
	p.best_rogue_round = 9
	var q = script.from_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	assert_eq(q.best_rogue_round, 9)
	assert_eq(typeof(q.best_rogue_round), TYPE_INT)
	assert_eq(script.from_dict({}).best_rogue_round, 0, "old saves start at 0")
	assert_eq(script.from_dict({"best_rogue_round": -3}).best_rogue_round, 0)
