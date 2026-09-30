extends GutTest
# Task 192: the windsock stands near the slingshot and points with each shot's weather (via WeatherFx).

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_192_save.json"


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


func test_wind_sock_in_the_world() -> void:
	var main = _main()
	var sock = _find(main, "WindSock")
	assert_not_null(sock, "WorldBuilder adds a WindSock")
	if sock == null:
		return
	assert_eq(main.weather_fx.windsock, sock)
	assert_eq(sock.get_index(), main.kites.get_index() + 1, "drawn right after the kites")
	main.start_rogue(5)
	main.rogue.weather = "tailwind"
	main._begin_aim()
	assert_eq(sock.direction, 1.0, "points with the tailwind")
	main.rogue.weather = "headwind"
	main._begin_aim()
	assert_eq(sock.direction, -1.0)
	main.go_to_title()
	main.start_game()
	assert_eq(sock.direction, 0.0, "no wind in classic")
