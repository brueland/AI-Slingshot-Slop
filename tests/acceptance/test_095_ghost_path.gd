extends GutTest
# Task 095: RunSession records the flight path; the best classic run's path is saved (Progress.best_path) and drawn
# as a faint dotted ghost line (scripts/game/ghost_path.gd) on later classic shots.

const PATH := "res://scripts/game/ghost_path.gd"
const SESSION := "res://scripts/core/run_session.gd"
const STATS := "res://scripts/core/player_stats.gd"
const PROGRESS := "res://scripts/core/progress.gd"
const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_095_save.json"
const FULL_PULL_45 := Vector2(-84.852814, 84.852814)


func before_each() -> void:
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func after_each() -> void:
	before_each()


func _fly(main) -> void:
	for i in 20000:
		if main.state_name() != "FLIGHT":
			return
		main.advance(1.0 / 60.0)


func test_session_records_its_path() -> void:
	var s = load(SESSION).new(load(STATS).from_levels({}), 1)
	assert_eq(s.get("path"), PackedVector2Array(), "empty before launch")
	s.launch_from_pull(FULL_PULL_45)
	assert_eq(s.path.size(), 1)
	assert_eq(s.path[0], Vector2(0.0, 2.0), "starts at the slingshot")
	var steps := 0
	while not s.is_finished():
		s.step(1.0 / 60.0)
		steps += 1
	assert_eq(s.path[s.path.size() - 1], s.sim.position, "ends where the alien stopped")
	assert_between(s.path.size(), floori(steps / 6.0), floori(steps / 6.0) + 2, "one point every 6 steps")


func test_pack_and_unpack() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var g = load(PATH)
	assert_eq(g.pack(PackedVector2Array()), [])
	var small := PackedVector2Array([Vector2(0, 2), Vector2(1.234, 3.456), Vector2(2, 0)])
	var ps: Array = g.pack(small)
	assert_eq(ps.size(), 3)
	assert_almost_eq(float(ps[1][0]), 1.23, 0.0001, "rounded to centimeters")
	assert_almost_eq(float(ps[1][1]), 3.46, 0.0001)
	var long := PackedVector2Array()
	for i in 1001:
		long.append(Vector2(i * 0.5, 1.0))
	var packed: Array = g.pack(long)
	assert_lt(packed.size(), 202)
	assert_gt(packed.size(), 150)
	assert_eq(packed[packed.size() - 1], [500.0, 1.0], "keeps the last point")
	var back: PackedVector2Array = g.unpack(packed)
	assert_eq(back.size(), packed.size())
	assert_eq(back[0], Vector2(0, 1))
	assert_eq(g.unpack([[1, 2], "junk", [3], [4.5, 6]]), PackedVector2Array([Vector2(1, 2), Vector2(4.5, 6)]))


func test_best_path_is_saved() -> void:
	var script = load(PROGRESS)
	var p = script.new()
	assert_eq(p.get("best_path"), [])
	p.best_path = [[0.0, 2.0], [10.5, 7.25]]
	var q = script.from_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	assert_eq(q.best_path, [[0.0, 2.0], [10.5, 7.25]])
	assert_eq(script.from_dict({"best_path": [[1, 2], "x", [3]]}).best_path, [[1.0, 2.0]], "bad points are dropped")
	assert_eq(script.from_dict({}).best_path, [])


func test_main_shows_the_ghost_of_the_best_run() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var main = load(SCENE).instantiate()
	main.save_path = SAVE
	add_child_autofree(main)
	var ghost = main.get("ghost")
	assert_not_null(ghost, "main.ghost")
	if ghost == null:
		return
	assert_lt(ghost.get_index(), main.projectile_view.get_index(), "behind the alien")
	main.start_game()
	assert_eq(ghost.points.size(), 0, "no best run yet")
	main.launch_with_pull(FULL_PULL_45)
	_fly(main)
	assert_gt(main.progress.best_path.size(), 5, "the new best's path is kept")
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_eq(saved["best_path"].size(), main.progress.best_path.size(), "and saved")
	var best_path: Array = main.progress.best_path.duplicate(true)
	main.continue_to_shop()
	main.leave_shop()
	assert_eq(ghost.points, load(PATH).unpack(best_path), "the next shot shows the ghost")
	main.launch_with_pull(Vector2(-20, 5))
	_fly(main)
	assert_eq(main.progress.best_path, best_path, "a shorter run keeps the old ghost")
	await wait_process_frames(2)
	main.go_to_title()
	main.start_rogue(7)
	assert_eq(ghost.points.size(), 0, "no ghost in the roguelike")
