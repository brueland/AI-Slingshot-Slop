extends GutTest
# Task 046: scripts/ui/options_panel.gd (music and sound sliders) opened from an Options button on the title
# screen; moving a slider changes the volume right away and saves it.

const PATH := "res://scripts/ui/options_panel.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_046_save.json"


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_options_panel() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var o = load(PATH).new()
	add_child_autofree(o)
	watch_signals(o)
	assert_true(o is PanelContainer)
	assert_false(o.visible)
	for s in [o.music_slider, o.sfx_slider]:
		assert_true(s is HSlider)
		assert_almost_eq(s.min_value, 0.0, 0.0001)
		assert_almost_eq(s.max_value, 1.0, 0.0001)
	o.set_values(0.6, 0.2)
	assert_almost_eq(o.music_slider.value, 0.6, 0.0001)
	assert_almost_eq(o.sfx_slider.value, 0.2, 0.0001)
	assert_signal_not_emitted(o, "volume_changed", "set_values does not emit")
	o.music_slider.value = 0.3
	assert_signal_emitted_with_parameters(o, "volume_changed", ["music", 0.3])
	o.sfx_slider.value = 0.45
	assert_signal_emitted_with_parameters(o, "volume_changed", ["sfx", 0.45])
	o.close_button.pressed.emit()
	assert_signal_emitted(o, "closed")


func test_main_options_from_the_title() -> void:
	if not ResourceLoader.exists(SCENE):
		fail_test("missing " + SCENE)
		return
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var op = main.get("options_panel")
	assert_not_null(op, "main.options_panel")
	assert_true(main.title_panel.get("options_button") is Button, "the title has an Options button")
	if op == null or not main.title_panel.get("options_button") is Button:
		return
	assert_eq(main.title_panel.options_button.text, "Options")
	assert_false(op.visible)
	main.title_panel.options_button.pressed.emit()
	assert_true(op.visible)
	assert_almost_eq(op.music_slider.value, 0.8, 0.0001, "sliders show the saved volumes")
	op.music_slider.value = 0.4
	assert_almost_eq(float(main.progress.settings["music_volume"]), 0.4, 0.0001)
	assert_almost_eq(main.audio.music_volume, 0.4, 0.0001, "applied right away")
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_true(saved is Dictionary)
	if saved is Dictionary:
		assert_almost_eq(float(saved.get("settings", {}).get("music_volume", -1.0)), 0.4, 0.0001, "and saved")
	op.close_button.pressed.emit()
	assert_false(op.visible)
