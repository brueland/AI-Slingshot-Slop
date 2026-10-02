extends GutTest
# Task 083: scripts/core/hats.gd, cosmetic hats that unlock by playing, and Progress.hat (the hat being worn),
# saved with the rest of the progress.

const PATH := "res://scripts/core/hats.gd"
const PROGRESS := "res://scripts/core/progress.gd"


func _hats():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func test_list() -> void:
	var h = _hats()
	if h == null:
		return
	var ids := ["none", "party", "propeller", "chef", "top_hat", "wizard", "crown"]
	var names := ["No hat", "Party Hat", "Propeller Cap", "Chef's Toque", "Top Hat", "Wizard Hat", "Crown"]
	assert_eq(h.LIST.size(), 10, "three balloon hats since task 275")
	for i in mini(h.LIST.size(), 7):
		assert_eq(h.LIST[i]["id"], ids[i])
		assert_eq(h.LIST[i]["name"], names[i])
	assert_eq(h.get_def("crown").get("hint"), "Reach 1000 m")
	assert_eq(h.get_def("sombrero"), {})


func test_unlock_rules() -> void:
	var h = _hats()
	if h == null:
		return
	var p = load(PROGRESS).new()
	assert_eq(h.unlocked(p), ["none"], "a new player only has no hat")
	p.total_runs = 1
	assert_true(h.is_unlocked("party", p))
	p.best_distance = 99.9
	assert_false(h.is_unlocked("propeller", p))
	p.best_distance = 100.0
	assert_true(h.is_unlocked("propeller", p))
	p.lifetime["stars"] = 25
	assert_true(h.is_unlocked("chef", p))
	p.levels = {"power": 5, "aero": 4}
	assert_false(h.is_unlocked("top_hat", p))
	p.levels["guide"] = 1
	assert_true(h.is_unlocked("top_hat", p))
	p.best_rogue_round = 5
	assert_true(h.is_unlocked("wizard", p))
	assert_false(h.is_unlocked("crown", p))
	p.goal_reached = true
	assert_eq(h.unlocked(p), ["none", "party", "propeller", "chef", "top_hat", "wizard", "crown"])
	assert_false(h.is_unlocked("sombrero", p))


func test_newly_unlocked() -> void:
	var h = _hats()
	if h == null:
		return
	var p = load(PROGRESS).new()
	var before: Array = h.unlocked(p)
	p.total_runs = 1
	p.best_distance = 120.0
	assert_eq(h.newly_unlocked(before, p), ["party", "propeller"])
	assert_eq(h.newly_unlocked(h.unlocked(p), p), [], "nothing new")


func test_progress_saves_the_hat() -> void:
	if _hats() == null:
		return
	var script = load(PROGRESS)
	var p = script.new()
	assert_eq(p.get("hat"), "none")
	p.hat = "wizard"
	var q = script.from_dict(JSON.parse_string(JSON.stringify(p.to_dict())))
	assert_eq(q.hat, "wizard")
	assert_eq(script.from_dict({}).hat, "none", "old saves wear no hat")
	assert_eq(script.from_dict({"hat": "sombrero"}).hat, "none", "unknown hats are dropped")
