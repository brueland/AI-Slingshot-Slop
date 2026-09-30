extends GutTest
# Task 178: an Achievements panel lists every achievement, earned or not, with how to earn it.

const PATH := "res://scripts/ui/achievements_panel.gd"


func test_achievements_panel() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var progress := Progress.new()
	progress.achievements.append("bouncy")
	var lines: PackedStringArray = load(PATH).lines(progress)
	assert_eq(lines.size(), Achievements.LIST.size())
	assert_eq(lines[0], "[ ] Liftoff - Finish your first run")
	assert_eq(lines[1], "[x] Bouncy Castle - Bounce 8 times in one run")
	var panel = load(PATH).new()
	add_child_autofree(panel)
	assert_false(panel.visible, "hidden at first")
	panel.show_list(progress)
	assert_true(panel.visible)
	assert_eq(panel.count_label.text, "1 of %d earned" % Achievements.LIST.size())
	assert_eq(panel.list_label.text, "\n".join(lines))
	watch_signals(panel)
	panel.close_button.pressed.emit()
	assert_signal_emitted(panel, "closed")
