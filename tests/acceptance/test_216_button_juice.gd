extends GutTest
# Task 216: every button is springy: it grows a little under the mouse and squashes while held down.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_216_save.json"
const PULL := Vector2(-84.852814, 84.852814)


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


func _on_screen(main, control: Control, what: String) -> void:
	assert_true(main.get_viewport().get_visible_rect().encloses(control.get_global_rect()), what + " is on screen")


func test_springy_buttons() -> void:
	var main = _main()
	await wait_process_frames(2)
	var buttons: Array = main.ui_layer.find_children("*", "Button", true, false)
	assert_gt(buttons.size(), 20)
	for b in buttons:
		assert_gt(b.button_down.get_connections().size(), 0, str(b.name) + " is springy")
	var play = main.title_panel.play_button
	assert_almost_eq(play.pivot_offset, play.size / 2.0, Vector2(0.5, 0.5), "it springs from its center")
	play.mouse_entered.emit()
	await wait_seconds(0.25)
	assert_almost_eq(play.scale.x, 1.06, 0.01, "grows under the mouse")
	play.button_down.emit()
	await wait_seconds(0.25)
	assert_almost_eq(play.scale.x, 0.94, 0.01, "squashes when pressed")
	play.mouse_exited.emit()
	await wait_seconds(0.25)
	assert_almost_eq(play.scale.x, 1.0, 0.01, "back to normal")
