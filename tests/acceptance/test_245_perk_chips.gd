extends GutTest
# Task 245: scripts/ui/perk_chips.gd shows the roguelike perks as small colored boxes, one per perk with a count badge
# ("Stronger Bands" + "x3"), in the order they were first taken, instead of one long line of text.

const PATH := "res://scripts/ui/perk_chips.gd"


func _texts(node: Node) -> Array:
	var out := []
	for label in node.find_children("*", "Label", true, false):
		out.append(label.text)
	return out


func test_perk_chips() -> void:
	var chips = load(PATH).new()
	add_child_autofree(chips)
	assert_true(chips is HFlowContainer)
	assert_eq(chips.mouse_filter, Control.MOUSE_FILTER_IGNORE, "never blocks the slingshot")
	assert_false(chips.visible, "hidden without perks")
	chips.show_perks(["power", "aero", "power", "boost", "power", "steady", "aero"])
	assert_true(chips.visible)
	assert_eq(chips.get_child_count(), 4, "one box per perk")
	assert_eq(chips.chip_texts(), ["Stronger Bands x3", "Sleek Shell x2", "Rocket x1", "Steady Hand x1"])
	var first = chips.get_child(0)
	assert_true(first is PanelContainer, "a box")
	assert_eq(_texts(first), ["Stronger Bands", "x3"], "the name and the count")
	for label in chips.find_children("*", "Label", true, false):
		assert_eq(label.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	chips.show_perks(["heavy"])
	assert_eq(chips.get_child_count(), 1, "the boxes are rebuilt")
	assert_eq(chips.chip_texts(), ["Heavy Core x1"])
	chips.show_perks([])
	assert_false(chips.visible)
	for p in RoguePerks.LIST:
		assert_true(chips.COLORS.has(p["id"]), "a color for " + str(p["id"]))
