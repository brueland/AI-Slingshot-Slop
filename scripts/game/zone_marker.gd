class_name ZoneMarker
extends Node2D
## The roguelike's landing zone on the field: a green band on the ground between the zone's edges, a flag at each
## end, and "STOP HERE" above it. Shown only while the goal (or a part of a boss goal) is a zone.

const BAND_COLOR := Color(0.45, 1.0, 0.45, 0.35)
const FLAG_COLOR := Color(0.2, 0.75, 0.3)
## The dip under the zone: a shaded hollow where the flat grass was, and grass along its slopes and floor.
const DIP_COLOR := Color(0.15, 0.32, 0.12)
const DIP_GRASS := Color(0.49, 0.77, 0.16)
## The ground's grass is drawn this many pixels above the ground line.
const GRASS_TOP: float = 8.0

var zones: Array[Vector2] = []


## The zones of `goal` as (start, end) in meters: its own for a zone goal, a boss goal's zone parts, none otherwise.
static func zones_for(goal: Dictionary) -> Array[Vector2]:
	var out: Array[Vector2] = []
	match str(goal.get("type", "")):
		"zone":
			var start := float(goal.get("target", 0.0))
			out.append(Vector2(start, start + RogueGoals.ZONE_WIDTH))
		"boss":
			for part in goal.get("parts", []):
				out.append_array(zones_for(part))
	return out


func show_goal(goal: Dictionary) -> void:
	zones = zones_for(goal)
	visible = not zones.is_empty()
	queue_redraw()


func _draw() -> void:
	var font := UiTheme.game_font(700)
	for zone in zones:
		var a := WorldView.world_to_screen(Vector2(zone.x, 0.0))
		var b := WorldView.world_to_screen(Vector2(zone.y, 0.0))
		draw_rect(Rect2(a + Vector2(0, -48), Vector2(b.x - a.x, 56)), BAND_COLOR)
		_draw_dip(dip_outline(zone))
		for x in [a.x, b.x]:
			draw_line(Vector2(x, 6), Vector2(x, -72), Color(0.95, 0.95, 0.95), 3.0)
			draw_colored_polygon(PackedVector2Array([Vector2(x, -72), Vector2(x + 22, -63), Vector2(x, -54)]), FLAG_COLOR)
		var at := Vector2((a.x + b.x) / 2.0 - 52.0, -84.0)
		draw_string_outline(font, at, "STOP HERE", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 6, Color(0.05, 0.1, 0.05))
		draw_string(font, at, "STOP HERE", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)


## The ground's outline through the dip under `zone`, in screen pixels: the top of the near slope, the floor's two
## ends, and the top of the far slope (Balance.DIP_SLOPE meters outside the zone, Balance.DIP_DEPTH down).
static func dip_outline(zone: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.append(WorldView.world_to_screen(Vector2(zone.x - Balance.DIP_SLOPE, 0.0)))
	out.append(WorldView.world_to_screen(Vector2(zone.x, -Balance.DIP_DEPTH)))
	out.append(WorldView.world_to_screen(Vector2(zone.y, -Balance.DIP_DEPTH)))
	out.append(WorldView.world_to_screen(Vector2(zone.y + Balance.DIP_SLOPE, 0.0)))
	return out


## Draws a dip from its outline: the shaded hollow covers the flat grass across it, and grass follows its slopes
## and floor.
func _draw_dip(outline: PackedVector2Array) -> void:
	var surface := PackedVector2Array()
	for p in outline:
		surface.append(p + Vector2(0.0, -GRASS_TOP))
	var hollow := surface.duplicate()
	hollow.append(Vector2(outline[3].x, -GRASS_TOP - 2.0))
	hollow.append(Vector2(outline[0].x, -GRASS_TOP - 2.0))
	draw_colored_polygon(hollow, DIP_COLOR)
	draw_polyline(surface, DIP_GRASS, 6.0)
