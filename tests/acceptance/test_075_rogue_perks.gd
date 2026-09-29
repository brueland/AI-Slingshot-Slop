extends GutTest
# Task 075: scripts/core/rogue_perks.gd, eight roguelike perks (some with trade-offs) that stack with no cap,
# applied to a copy of the base stats, and a seeded offer of three different perks.

const PATH := "res://scripts/core/rogue_perks.gd"
const STATS := "res://scripts/core/player_stats.gd"


func _p():
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return null
	return load(PATH)


func _base():
	return load(STATS).from_levels({})


func test_list() -> void:
	var p = _p()
	if p == null:
		return
	var ids := ["power", "height", "aero", "bounce", "boost", "heavy", "feather", "steady"]
	var names := ["Stronger Bands", "Taller Frame", "Sleek Shell", "Rubber Coat", "Rocket", "Heavy Core",
		"Feather Shell", "Steady Hand"]
	assert_eq(p.LIST.size(), 8)
	for i in mini(p.LIST.size(), 8):
		assert_eq(p.LIST[i]["id"], ids[i])
		assert_eq(p.LIST[i]["name"], names[i])
		assert_true(str(p.LIST[i]["description"]).length() > 0)
	assert_eq(p.get_def("heavy").get("name"), "Heavy Core")
	assert_eq(p.get_def("nope"), {})


func test_single_perks() -> void:
	var p = _p()
	if p == null:
		return
	var base = _base()
	assert_almost_eq(p.apply(base, ["power"]).max_speed, 22.0 * 1.15, 0.0001)
	assert_almost_eq(p.apply(base, ["height"]).launch_height, 3.5, 0.0001)
	assert_almost_eq(p.apply(base, ["aero"]).drag, 0.002 * 0.8, 0.0000001)
	assert_almost_eq(p.apply(base, ["bounce"]).restitution, 0.42, 0.0001)
	assert_eq(p.apply(base, ["boost"]).boost_charges, 1)
	var heavy = p.apply(base, ["heavy"])
	assert_almost_eq(heavy.max_speed, 22.0 * 1.3, 0.0001)
	assert_almost_eq(heavy.restitution, 0.25, 0.0001, "trade-off: less bounce")
	var feather = p.apply(base, ["feather"])
	assert_almost_eq(feather.drag, 0.002 * 0.6, 0.0000001)
	assert_almost_eq(feather.max_speed, 22.0 * 0.9, 0.0001, "trade-off: less speed")
	var steady = p.apply(base, ["steady"])
	assert_almost_eq(steady.max_speed, 22.0, 0.0001, "Steady Hand changes no stats")


func test_perks_stack_without_a_cap() -> void:
	var p = _p()
	if p == null:
		return
	var base = _base()
	var fast = p.apply(base, ["power", "power", "power"])
	assert_almost_eq(fast.max_speed, 22.0 * pow(1.15, 3), 0.001)
	var rockets = p.apply(base, ["boost", "boost", "boost", "boost", "boost"])
	assert_eq(rockets.boost_charges, 5, "more than the classic maximum of 3")
	var rubber = p.apply(base, ["bounce", "bounce", "bounce", "bounce", "bounce", "bounce", "bounce", "bounce", "bounce"])
	assert_almost_eq(rubber.restitution, 0.9, 0.0001, "bounciness is capped at 0.9 so bounces still end")
	var lead = p.apply(base, ["heavy", "heavy", "heavy"])
	assert_almost_eq(lead.restitution, 0.1, 0.0001, "and never goes below 0.1")
	assert_almost_eq(base.max_speed, 22.0, 0.0001, "the base stats are not changed")


func test_offer() -> void:
	var p = _p()
	if p == null:
		return
	var o: Array = p.offer(99, [])
	assert_eq(o.size(), 3)
	var unique := {}
	for id in o:
		unique[id] = true
		assert_false(p.get_def(id).is_empty(), "offered id %s exists" % id)
	assert_eq(unique.size(), 3, "three different perks")
	assert_eq(p.offer(99, []), o, "same seed, same offer")
	assert_eq(p.offer(5, [], 2).size(), 2)
	var ever_steady := false
	for s in 200:
		var offer: Array = p.offer(s, ["steady"])
		assert_false(offer.has("steady"), "Steady Hand is not offered again once owned")
		if p.offer(s, []).has("steady"):
			ever_steady = true
	assert_true(ever_steady, "Steady Hand is offered sometimes")
