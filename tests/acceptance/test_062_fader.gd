extends GutTest
# Task 062: scripts/ui/fader.gd, a full-screen black overlay on its own top CanvasLayer that fades out over 0.3 s;
# main.gd flashes it on every screen change except the launch (the flight must start instantly).

const PATH := "res://scripts/ui/fader.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_062_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_fader_fades_out() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var f = load(PATH).new()
	add_child_autofree(f)
	assert_true(f is CanvasLayer)
	assert_eq(f.layer, 10, "above the UI")
	assert_true(f.rect is ColorRect)
	assert_eq(f.rect.mouse_filter, Control.MOUSE_FILTER_IGNORE, "never blocks clicks")
	assert_almost_eq(f.rect.anchor_right, 1.0, 0.001, "covers the whole screen")
	assert_almost_eq(f.rect.anchor_bottom, 1.0, 0.001)
	assert_almost_eq(f.alpha(), 0.0, 0.0001, "invisible until flashed")
	f.flash(0.4)
	assert_almost_eq(f.alpha(), 1.0, 0.0001)
	f.advance(0.2)
	assert_almost_eq(f.alpha(), 0.5, 0.0001)
	f.advance(1.0)
	assert_almost_eq(f.alpha(), 0.0, 0.0001)
	f.flash()
	assert_almost_eq(f.duration, 0.3, 0.0001, "0.3 s by default")


func test_main_fades_on_screen_changes_but_not_on_launch() -> void:
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var f = main.get("fader")
	assert_not_null(f, "main.fader")
	if f == null:
		return
	assert_almost_eq(f.alpha(), 0.0, 0.0001)
	main.start_game()
	assert_almost_eq(f.alpha(), 1.0, 0.0001, "title -> aim fades")
	f.advance(1.0)
	main.launch_with_pull(FULL_PULL_45)
	assert_almost_eq(f.alpha(), 0.0, 0.0001, "no fade on launch")
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	assert_almost_eq(f.alpha(), 1.0, 0.0001, "results fade in")
