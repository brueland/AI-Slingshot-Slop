extends GutTest
# Task 179: a How to play panel lists the controls and what each mode is about.

const PATH := "res://scripts/ui/help_panel.gd"


func test_help_panel() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var script = load(PATH)
	var text: String = script.help_text()
	assert_eq(text.split("\n").size(), 6, "one line per entry")
	for word in ["Drag", "arrow keys", "Space", "R to repeat", "Esc", "Classic", "Roguelike"]:
		assert_true(text.contains(word), "mentions " + word)
	var panel = script.new()
	add_child_autofree(panel)
	assert_false(panel.visible, "hidden at first")
	assert_eq(panel.text_label.text, text)
	watch_signals(panel)
	panel.close_button.pressed.emit()
	assert_signal_emitted(panel, "closed")
