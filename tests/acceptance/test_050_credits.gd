extends GutTest
# Task 050: scripts/ui/credits_panel.gd shows CREDITS.md (ElvGames music and Kenney art/sound credits,
# required by the music license), opened from a Credits button on the title screen.

const PATH := "res://scripts/ui/credits_panel.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_050_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_credits_text_names_the_authors() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var cp = load(PATH)
	var text: String = cp.credits_text()
	assert_true(text.contains("ElvGames"), "credits ElvGames (music license)")
	assert_true(text.contains("Kenney"), "credits Kenney (art and sounds)")
	assert_true(cp.FALLBACK.contains("ElvGames") and cp.FALLBACK.contains("Kenney"),
		"the fallback text (used when CREDITS.md is not exported) credits both too")


func test_credits_panel() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var p = load(PATH).new()
	add_child_autofree(p)
	watch_signals(p)
	assert_true(p is PanelContainer)
	assert_false(p.visible)
	assert_true(p.text_label.text.contains("ElvGames"))
	p.close_button.pressed.emit()
	assert_signal_emitted(p, "closed")


func test_main_opens_credits_from_the_title() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var cp = main.get("credits_panel")
	assert_not_null(cp, "main.credits_panel")
	assert_true(main.title_panel.get("credits_button") is Button, "the title has a Credits button")
	if cp == null or not main.title_panel.get("credits_button") is Button:
		return
	assert_eq(main.title_panel.credits_button.text, "Credits")
	main.title_panel.credits_button.pressed.emit()
	assert_true(cp.visible)
	cp.close_button.pressed.emit()
	assert_false(cp.visible)
