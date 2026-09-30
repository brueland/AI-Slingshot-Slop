extends GutTest
# Task 194: the hot-air balloons are in the world, drawn behind the course and the alien.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_194_save.json"


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


## The first child of `main` whose script has class_name `name` (null when there is none).
func _find(main, name: String):
	for child in main.get_children():
		var script = child.get_script()
		if script != null and script.get_global_name() == name:
			return child
	return null


func test_balloons_in_the_world() -> void:
	var main = _main()
	var sky = _find(main, "SkyBalloons")
	assert_not_null(sky, "WorldBuilder adds SkyBalloons")
	if sky == null:
		return
	assert_lt(sky.get_index(), main.course_view.get_index(), "behind the course")
	assert_lt(sky.get_index(), main.projectile_view.get_index(), "behind the alien")
	var count := 0
	for child in main.get_children():
		if child.get_script() != null and child.get_script().get_global_name() == "SkyBalloons":
			count += 1
	assert_eq(count, 1, "just one set")
	await wait_seconds(0.3)
	assert_gt(sky.time, 0.2, "drifting with real frames")
