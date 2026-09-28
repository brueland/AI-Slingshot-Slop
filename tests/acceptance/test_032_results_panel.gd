extends GutTest
# Task 032: scripts/ui/results_panel.gd shows a run's score breakdown and a Continue button.

const PATH := "res://scripts/ui/results_panel.gd"
const RESULT := {
	"distance": 104.7, "distance_points": 104, "stars": 3, "star_points": 45, "bounces": 4, "bounce_points": 12,
	"multiplier": 1.25, "total": 201, "coins": 201,
	"milestones": [{"distance": 100.0, "reward": 50, "name": "Century"}],
}


func _panel():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	var p = load(PATH).new()
	add_child_autofree(p)
	return p


func test_hidden_until_shown() -> void:
	var p = _panel()
	if p == null:
		return
	assert_true(p is PanelContainer)
	assert_false(p.visible)


func test_show_result_texts() -> void:
	var p = _panel()
	if p == null:
		return
	p.show_result(RESULT, true)
	assert_true(p.visible)
	assert_eq(p.title_label.text, "New best!")
	assert_eq(p.distance_label.text, "Distance: 104 m")
	assert_eq(p.stars_label.text, "Stars: 3 (+45)")
	assert_eq(p.bounces_label.text, "Bounces: 4 (+12)")
	assert_eq(p.multiplier_label.text, "Multiplier: x1.25")
	assert_eq(p.total_label.text, "Total: 201")
	assert_eq(p.coins_label.text, "Coins earned: +201")
	assert_eq(p.milestones_label.text, "Milestone reached: Century (+50)")
	assert_true(p.milestones_label.visible)


func test_no_milestones_and_not_best() -> void:
	var p = _panel()
	if p == null:
		return
	var r := RESULT.duplicate()
	r["milestones"] = []
	p.show_result(r, false)
	assert_eq(p.title_label.text, "Run complete")
	assert_eq(p.milestones_label.text, "")
	assert_false(p.milestones_label.visible)


func test_continue_button_emits() -> void:
	var p = _panel()
	if p == null:
		return
	watch_signals(p)
	assert_true(p.continue_button is Button)
	assert_eq(p.continue_button.text, "Continue")
	p.continue_button.pressed.emit()
	assert_signal_emitted(p, "continue_pressed")
