extends GutTest
# Task 015: scripts/core/save_system.gd saves and loads Progress as JSON (docs/DESIGN.md section 9).

const PATH := "res://scripts/core/save_system.gd"
const PROGRESS_PATH := "res://scripts/core/progress.gd"
const FILE := "user://test_015_save.json"


func _ss():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func before_each() -> void:
	_remove(FILE)


func after_each() -> void:
	_remove(FILE)


func test_default_path() -> void:
	var ss = _ss()
	if ss == null:
		return
	assert_eq(ss.DEFAULT_PATH, "user://save.json")


func test_save_then_load() -> void:
	var ss = _ss()
	if ss == null:
		return
	var p = load(PROGRESS_PATH).new()
	p.coins = 250
	p.levels = {"bounce": 2}
	p.best_distance = 77.5
	p.total_runs = 4
	assert_true(ss.save_progress(p, FILE))
	assert_true(FileAccess.file_exists(FILE))
	assert_true(FileAccess.get_file_as_string(FILE).contains("\"coins\""), "the save file is JSON")
	var q = ss.load_progress(FILE)
	assert_eq(q.coins, 250)
	assert_eq(q.level_of("bounce"), 2)
	assert_almost_eq(q.best_distance, 77.5, 0.0001)
	assert_eq(q.total_runs, 4)


func test_missing_file_gives_new_progress() -> void:
	var ss = _ss()
	if ss == null:
		return
	var q = ss.load_progress("user://test_015_does_not_exist.json")
	assert_not_null(q)
	if q != null:
		assert_eq(q.coins, 0)
		assert_eq(q.total_runs, 0)


func test_corrupt_file_gives_new_progress_without_errors() -> void:
	var ss = _ss()
	if ss == null:
		return
	var f := FileAccess.open(FILE, FileAccess.WRITE)
	f.store_string("{not valid json")
	f.close()
	var q = ss.load_progress(FILE)
	assert_not_null(q)
	if q != null:
		assert_eq(q.coins, 0)
	var g := FileAccess.open(FILE, FileAccess.WRITE)
	g.store_string("[1, 2, 3]")
	g.close()
	var r = ss.load_progress(FILE)
	assert_not_null(r, "valid JSON that is not an object also gives a new Progress")


func test_delete_save() -> void:
	var ss = _ss()
	if ss == null:
		return
	ss.save_progress(load(PROGRESS_PATH).new(), FILE)
	assert_true(FileAccess.file_exists(FILE))
	ss.delete_save(FILE)
	assert_false(FileAccess.file_exists(FILE))
	ss.delete_save(FILE)
	assert_false(FileAccess.file_exists(FILE), "deleting a missing save is fine")
