extends GutTest
# Task 148: the title shows today's challenge at the bottom ("Today's challenge: fly 250 m", or "done!").

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_148_save.json"


func before_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func after_each() -> void:
	before_each()


func _main():
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func _fly(main, pull: Vector2) -> void:
	main.launch_with_pull(pull)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_challenge_label() -> void:
	var d = load("res://scripts/core/daily.gd")
	var main = _main()
	var label = main.ui_layer.get("challenge_label")
	assert_true(label is Label, "ui_layer.challenge_label")
	if not label is Label:
		return
	assert_true(label.visible)
	assert_eq(label.text, "Today's challenge: fly %d m" % roundi(d.challenge_distance(d.today())))
	await wait_process_frames(2)
	var screen: Rect2 = main.get_viewport().get_visible_rect()
	assert_true(screen.encloses(label.get_global_rect()))
	assert_gt(label.get_global_rect().position.y, main.title_panel.bottom_bar.get_global_rect().end.y, "under the title's buttons (task 217)")
	assert_false(label.get_global_rect().intersects(main.ui_layer.tip_label.get_global_rect()), "above the tip")
	main.progress.challenge_day = d.key_for(d.today())
	main.go_to_title()
	assert_eq(label.text, "Today's challenge: done!")
	main.start_game()
	assert_false(label.visible, "only on the title")
