extends GutTest
# Task 037: main.gd loads progress from save_path in _ready() and saves it after every run and purchase.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_037_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func _remove() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func before_each() -> void:
	_remove()


func after_each() -> void:
	_remove()


func _main():
	if not ResourceLoader.exists(SCENE):
		fail_test("missing " + SCENE)
		return null
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	return main


func _write_save(data: Dictionary) -> void:
	var f := FileAccess.open(SAVE, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()


func _read_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	return parsed if parsed is Dictionary else {}


func test_loads_progress_on_start() -> void:
	_write_save({"coins": 500, "levels": {"power": 2}, "best_distance": 80.0, "total_runs": 4})
	var main = _main()
	if main == null:
		return
	assert_eq(main.progress.coins, 500)
	assert_eq(main.progress.level_of("power"), 2)
	assert_eq(main.progress.total_runs, 4)
	main.start_game()
	assert_almost_eq(main.session.stats.max_speed, 33.0, 0.0001)


func test_missing_save_starts_fresh() -> void:
	var main = _main()
	if main == null:
		return
	assert_eq(main.progress.coins, 0)
	assert_eq(main.progress.total_runs, 0)


func test_saves_after_a_run_and_a_purchase() -> void:
	var main = _main()
	if main == null:
		return
	main.start_game()
	main.launch_with_pull(FULL_PULL_45)
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)
	var saved := _read_save()
	assert_eq(int(saved.get("total_runs", 0)), 1, "saved when the run ends")
	assert_eq(int(saved.get("coins", -1)), main.progress.coins)
	main.continue_to_shop()
	main.progress.add_coins(1000)
	assert_true(main.buy_upgrade("height"))
	saved = _read_save()
	assert_eq(int(saved.get("levels", {}).get("height", 0)), 1, "saved after buying")
	assert_eq(int(saved.get("coins", -1)), main.progress.coins)
