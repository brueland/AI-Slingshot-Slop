extends GutTest
# Task 130: the last 5 roguelike runs (rounds cleared, seed, number of perks) are remembered, newest first, and saved.

const SCENE := "res://scenes/main.tscn"
const SAVE := "user://test_130_save.json"


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


func _lose_a_run(main, run_seed: int, rounds: int) -> void:
	main.start_rogue(run_seed)
	main.rogue.rounds_cleared = rounds
	main.rogue.lives = 1
	main.launch_with_pull(Vector2(-12, 0))
	for i in 20000:
		if main.state_name() != "FLIGHT":
			break
		main.advance(1.0 / 60.0)


func test_history_in_progress() -> void:
	var script = load("res://scripts/core/progress.gd")
	var p = script.new()
	assert_eq(p.get("rogue_history"), [])
	for i in 7:
		p.add_rogue_run(i, 100 + i, i * 2)
	assert_eq(p.rogue_history.size(), 5, "only the last 5 runs")
	assert_eq(p.rogue_history[0], {"rounds": 6, "seed": 106, "perks": 12}, "newest first")
	var q = script.from_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	assert_eq(q.rogue_history.size(), 5)
	assert_eq(int(q.rogue_history[0]["rounds"]), 6)
	assert_eq(typeof(q.rogue_history[0]["seed"]), TYPE_INT)
	assert_eq(script.from_dict({}).rogue_history, [], "old saves have none")
	assert_eq(script.from_dict({"rogue_history": ["junk", {"rounds": -3}]}).rogue_history, [{"rounds": 0, "seed": 0, "perks": 0}])


func test_a_finished_run_is_remembered() -> void:
	var main = _main()
	_lose_a_run(main, 77, 4)
	assert_true(main.rogue.is_over())
	assert_eq(main.progress.rogue_history.size(), 1)
	assert_eq(int(main.progress.rogue_history[0]["rounds"]), 4)
	assert_eq(int(main.progress.rogue_history[0]["seed"]), 77)
	var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	assert_eq(saved["rogue_history"].size(), 1, "saved")
