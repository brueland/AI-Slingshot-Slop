extends GutTest
# Task 222: the shop has one column per upgrade category, with the coins above and a big orange Launch! below.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_222_save.json"
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


func test_shop_columns() -> void:
	var main = _main()
	main.progress.coins = 500
	main.start_game()
	_fly(main, PULL)
	main.continue_to_shop()
	var shop = main.shop_panel
	var columns: Array = []
	for category in UpgradeCatalog.CATEGORIES:
		var column = shop.header_labels[category].get_parent()
		assert_true(column is VBoxContainer, category + " has a column")
		for id in UpgradeCatalog.ids_in_category(category):
			assert_eq(shop.buttons[id].get_parent(), column, id + " is in its category's column")
		columns.append(column)
	assert_true(columns[0].get_parent() is HBoxContainer and columns[0].get_parent() == columns[1].get_parent(), "side by side")
	assert_eq(shop.launch_button.theme_type_variation, "PrimaryButton")
	await wait_process_frames(3)
	_on_screen(main, shop, "the shop")
	assert_gt(shop.get_global_rect().position.y, 130.0, "clear of the pop-ups at the top")
	watch_signals(shop)
	shop.buttons["power"].pressed.emit()
	assert_signal_emitted(shop, "purchase_requested", "the buttons still work")
