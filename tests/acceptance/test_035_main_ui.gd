extends GutTest
# Task 035: main.gd puts the HUD, results panel and shop panel on a CanvasLayer, shows each in its state,
# and wires their buttons to the game flow.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_035_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func _main():
	if not ResourceLoader.exists(SCENE):
		fail_test("missing " + SCENE)
		return null
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func after_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func _fly(main) -> void:
	for i in 20000:
		if main.state_name() != "FLIGHT":
			return
		main.advance(1.0 / 60.0)


func test_ui_nodes_exist_on_a_canvas_layer() -> void:
	var main = _main()
	if main == null:
		return
	assert_true(main.get("ui_layer") is CanvasLayer, "main.ui_layer is a CanvasLayer")
	var want := {"hud": "res://scripts/ui/hud.gd", "results_panel": "res://scripts/ui/results_panel.gd",
		"shop_panel": "res://scripts/ui/shop_panel.gd"}
	for key in want:
		var node = main.get(key)
		assert_not_null(node, "main.%s must exist" % key)
		if node != null:
			assert_eq(node.get_script().resource_path, want[key])
			assert_eq(node.get_parent(), main.ui_layer, key + " lives on ui_layer")


func test_each_panel_shows_in_its_state() -> void:
	var main = _main()
	if main == null:
		return
	main.start_game()
	assert_true(main.hud.visible, "HUD while aiming")
	assert_false(main.results_panel.visible)
	assert_false(main.shop_panel.visible)
	main.launch_with_pull(FULL_PULL_45)
	for i in 30:
		main.advance(1.0 / 60.0)
	assert_eq(main.hud.distance_label.text, "Distance: %d m" % floori(main.session.sim.distance()),
		"the HUD follows the flight")
	_fly(main)
	assert_eq(main.state_name(), "RESULTS")
	assert_false(main.hud.visible)
	assert_true(main.results_panel.visible)
	assert_eq(main.results_panel.distance_label.text, "Distance: %d m" % int(main.last_result["distance_points"]))
	assert_true(main.last_result.get("new_best", false), "the first run is always a new best")
	assert_eq(main.results_panel.title_label.text, "New best!")


func test_buttons_drive_the_loop() -> void:
	var main = _main()
	if main == null:
		return
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	_fly(main)
	main.results_panel.continue_button.pressed.emit()
	assert_eq(main.state_name(), "SHOP")
	assert_true(main.shop_panel.visible)
	assert_false(main.results_panel.visible)
	assert_eq(main.shop_panel.coins_label.text, "Coins: %d" % main.progress.coins)
	main.progress.add_coins(1000)
	main.shop_panel.buttons["power"].pressed.emit()
	assert_eq(main.progress.level_of("power"), 1)
	assert_eq(main.shop_panel.buttons["power"].text, "Band Power  Lv 1/10  136 coins", "refreshed after buying")
	main.shop_panel.launch_button.pressed.emit()
	assert_eq(main.state_name(), "AIM")
	assert_false(main.shop_panel.visible)
	assert_true(main.hud.visible)
