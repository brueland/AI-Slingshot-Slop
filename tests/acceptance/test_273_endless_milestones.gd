extends GutTest
# Task 273: classic milestones never run out: after the five (up to 1000 m) a new one every 1000 m (reward = its
# distance, names in turn), with a flag on the course up to 8000 m.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_273_save.json"
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



func test_endless_milestones() -> void:
	var ms = load("res://scripts/core/milestones.gd")
	assert_eq(ms.more(0), {"distance": 2000.0, "reward": 2000, "name": "Cloud Surfer"})
	assert_eq(ms.more(1)["distance"], 3000.0)
	assert_eq(ms.more(6)["name"], "Cloud Surfer", "the names come round again")
	assert_eq(ms.next_milestone(1500.0)["distance"], 2000.0)
	assert_eq(ms.next_milestone(2000.0)["distance"], 3000.0)
	assert_eq(ms.next_milestone(4321.0)["distance"], 5000.0)
	var names := []
	for m in ms.newly_reached(900.0, 3500.0):
		names.append(m["name"])
	assert_eq(names, ["Moon Shot", "Cloud Surfer", "Jet Setter"])
	assert_eq(ms.up_to(8000.0).size(), 12)
	var p := Progress.new()
	var reached: Array = p.record_run(2100.0, 0)
	assert_eq(reached.size(), 6, "the five and Cloud Surfer")
	var main = _main()
	assert_eq(main.course_view.flags.size(), 34, "flags up to 30000 m since task 292")
	assert_eq(main.course_view.flag_distances[5], 2000.0, "a flag at 2000 m")
