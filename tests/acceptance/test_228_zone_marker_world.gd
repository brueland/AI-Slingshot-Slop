extends GutTest
# Task 228: the landing zone marker is on the field (behind the course items) whenever a roguelike shot has a zone.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_228_save.json"
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



func test_marker_in_the_world() -> void:
	var main = _main()
	var marker = main.get("zone_marker")
	assert_true(marker is ZoneMarker, "main.zone_marker")
	if not marker is ZoneMarker:
		return
	assert_lt(marker.get_index(), main.course_view.get_index(), "behind the course items")
	main.start_rogue(5)
	main.rogue.goal = {"type": "zone", "target": 40.0, "round": 3, "text": "Stop between 40 and 60 m"}
	main._begin_aim()
	assert_true(marker.visible, "a zone goal shows the marker")
	assert_eq(marker.zones, [Vector2(40, 60)])
	main.rogue.goal = {"type": "distance", "target": 40.0, "round": 3, "text": "Fly at least 40 m"}
	main._begin_aim()
	assert_false(marker.visible, "no zone, no marker")
	main.go_to_title()
	main.start_game()
	assert_false(marker.visible, "never in classic")
