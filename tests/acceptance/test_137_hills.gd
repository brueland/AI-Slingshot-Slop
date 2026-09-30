extends GutTest
# Task 137: soft rolling hills far behind the meadow, in their own background layer.

const PATH := "res://scripts/game/hills.gd"
const BG := "res://scripts/game/background.gd"


func test_hills() -> void:
	if not ResourceLoader.exists(PATH):
		fail_test("missing file " + PATH)
		return
	var h = load(PATH)
	var top: PackedVector2Array = h.outline(60.0, 60.0, 2.0)
	assert_eq(top.size(), 31, "a point every 60 px across 1800 px")
	for p in top:
		assert_between(p.y, -120.001, -59.999, "between base and base + height above the ground")
	var bg = load(BG).new()
	add_child_autofree(bg)
	assert_eq(bg.layers.size(), 2, "the sky and cloud layers are unchanged")
	assert_true(bg.get("hills_layer") is Parallax2D, "background.hills_layer")
	assert_eq(bg.hills.get_parent(), bg.hills_layer)
	assert_almost_eq(bg.hills_layer.scroll_scale.x, 0.3, 0.0001, "scrolls slower than the world")
	await wait_process_frames(2)
	pass_test("the hills draw without errors")
