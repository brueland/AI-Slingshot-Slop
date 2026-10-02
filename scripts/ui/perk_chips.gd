class_name PerkChips
extends HFlowContainer
## The roguelike perks taken so far as small colored boxes: one box per perk with how many times it was picked
## ("Stronger Bands" and a "x3" badge), in the order they were first taken. Hidden without perks; never blocks the mouse.

## A color per perk (unknown perks are grey).
const COLORS := {
	"power": Color(0.75, 0.27, 0.24), "height": Color(0.78, 0.48, 0.14), "aero": Color(0.18, 0.52, 0.72),
	"bounce": Color(0.24, 0.58, 0.3), "boost": Color(0.84, 0.38, 0.1), "heavy": Color(0.4, 0.4, 0.5),
	"feather": Color(0.34, 0.42, 0.78), "steady": Color(0.52, 0.33, 0.72),
}

## Perk id -> times picked, and the ids in the order they were first taken.
var counts: Dictionary = {}
var order: Array[String] = []


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(300, 0)
	add_theme_constant_override("h_separation", 6)
	add_theme_constant_override("v_separation", 6)
	hide()


## Shows a box for every perk in `perk_ids`; a perk picked again raises its count instead of adding a box.
func show_perks(perk_ids: Array) -> void:
	counts.clear()
	order.clear()
	for id in perk_ids:
		if not counts.has(id):
			order.append(id)
		counts[id] = int(counts.get(id, 0)) + 1
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for id in order:
		add_child(_chip(id, counts[id]))
	visible = not order.is_empty()


## What the boxes show, e.g. ["Stronger Bands x5", "Rocket x1"].
func chip_texts() -> Array[String]:
	var out: Array[String] = []
	for id in order:
		out.append("%s x%d" % [RoguePerks.get_def(id).get("name", id), counts[id]])
	return out


func _chip(id: String, count: int) -> PanelContainer:
	var box := PanelContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_stylebox_override("panel", _style(COLORS.get(id, Color(0.4, 0.4, 0.4)), 6, 7.0, 3.0))
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 5)
	box.add_child(row)
	row.add_child(_label(str(RoguePerks.get_def(id).get("name", id)), Color.WHITE))
	var badge := PanelContainer.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_theme_stylebox_override("panel", _style(Color(0.0, 0.0, 0.0, 0.35), 5, 4.0, 4.0))
	badge.add_child(_label("x%d" % count, Color(1.0, 0.86, 0.3)))
	row.add_child(badge)
	return box


func _label(text: String, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", color)
	return label


func _style(color: Color, radius: int, left: float, right: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.content_margin_left = left
	style.content_margin_right = right
	style.content_margin_top = 1.0
	style.content_margin_bottom = 1.0
	return style
