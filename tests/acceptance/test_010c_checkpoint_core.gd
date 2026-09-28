extends GutTest
# Checkpoint 1 (task 010c): milestone 1's core classes work together, follow docs/DESIGN.md, and the
# milestone is recorded in docs/PROGRESS.md.

const CORE := {
	"res://scripts/core/balance.gd": "Balance",
	"res://scripts/core/launch_math.gd": "LaunchMath",
	"res://scripts/core/flight_sim.gd": "FlightSim",
	"res://scripts/core/upgrade_catalog.gd": "UpgradeCatalog",
	"res://scripts/core/player_stats.gd": "PlayerStats",
	"res://scripts/core/scoring.gd": "Scoring",
}
const DT := 1.0 / 60.0


func _all_core_exist() -> bool:
	for path in CORE:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			return false
	return true


## Full-strength shot at 45 degrees with the given upgrade levels. Returns the stopped FlightSim.
func _shoot(levels: Dictionary, use_boosts: bool = false):
	var stats = load("res://scripts/core/player_stats.gd").from_levels(levels)
	var pull := Vector2(-1, 1).normalized() * 120.0
	var v: Vector2 = load("res://scripts/core/launch_math.gd").velocity_from_pull(pull, 120.0, stats.max_speed)
	var sim = load("res://scripts/core/flight_sim.gd").new()
	stats.apply_to(sim)
	sim.launch(Vector2(0, stats.launch_height), v)
	for i in 30000:
		if sim.stopped:
			break
		if use_boosts and sim.velocity.y < 0.0:
			sim.boost()
		sim.step(DT)
	return sim


func test_base_shot_distance_is_in_the_designed_range() -> void:
	if not _all_core_exist():
		return
	var sim = _shoot({})
	assert_true(sim.stopped, "the shot must come to a stop")
	assert_between(sim.distance(), 40.0, 70.0, "a shot with no upgrades flies about 50 m (got %.1f)" % sim.distance())


func test_every_distance_upgrade_helps() -> void:
	if not _all_core_exist():
		return
	var base: float = _shoot({}).distance()
	for id in ["power", "height", "aero", "bounce"]:
		var d: float = _shoot({id: 3}).distance()
		assert_gt(d, base, "%s level 3 must fly farther than no upgrades (%.1f vs %.1f)" % [id, d, base])


func test_boosts_help() -> void:
	if not _all_core_exist():
		return
	var without: float = _shoot({"boosts": 2}, false).distance()
	var with_boosts: float = _shoot({"boosts": 2}, true).distance()
	assert_gt(with_boosts, without + 10.0, "two boosts add distance (%.1f vs %.1f)" % [with_boosts, without])


func test_fully_upgraded_shot_reaches_far() -> void:
	if not _all_core_exist():
		return
	var levels := {}
	for id in load("res://scripts/core/upgrade_catalog.gd").ids():
		levels[id] = 99
	var sim = _shoot(levels, true)
	assert_true(sim.stopped)
	assert_gt(sim.distance(), 700.0, "max upgrades must fly far (got %.1f)" % sim.distance())


func test_score_of_a_real_shot() -> void:
	if not _all_core_exist():
		return
	var stats = load("res://scripts/core/player_stats.gd").from_levels({"bounce_bonus": 1})
	var sim = _shoot({"bounce_bonus": 1})
	var r: Dictionary = load("res://scripts/core/scoring.gd").compute(sim.distance(), 0, sim.bounce_count, stats)
	assert_eq(r.get("total"), floori(sim.distance()) + 3 * sim.bounce_count)


func test_core_files_follow_the_conventions() -> void:
	for path in CORE:
		if not ResourceLoader.exists(path):
			fail_test("missing file " + path)
			continue
		var text := FileAccess.get_file_as_string(path)
		assert_true(text.contains("class_name " + CORE[path]), "%s must declare class_name %s" % [path, CORE[path]])
		assert_true(text.contains("extends RefCounted"), path + " must extend RefCounted")
		assert_lt(text.split("\n").size(), 300, path + " must stay under 300 lines")
		assert_false(text.contains("print("), path + " must not print")


func test_progress_log_records_milestone_1() -> void:
	var text := FileAccess.get_file_as_string("res://docs/PROGRESS.md")
	assert_true(text.contains("Milestone 1: complete"),
		"add the line 'Milestone 1: complete' to docs/PROGRESS.md")
