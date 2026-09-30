class_name ZoneMarker
extends Node2D
## The roguelike's landing zone on the field: a green band on the ground between the zone's edges, a flag at each
## end, and "STOP HERE" above it. Shown only while the goal (or a part of a boss goal) is a zone.

const BAND_COLOR := Color(0.45, 1.0, 0.45, 0.35)
const FLAG_COLOR := Color(0.2, 0.75, 0.3)

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
		for x in [a.x, b.x]:
			draw_line(Vector2(x, 6), Vector2(x, -72), Color(0.95, 0.95, 0.95), 3.0)
			draw_colored_polygon(PackedVector2Array([Vector2(x, -72), Vector2(x + 22, -63), Vector2(x, -54)]), FLAG_COLOR)
		var at := Vector2((a.x + b.x) / 2.0 - 52.0, -84.0)
		draw_string_outline(font, at, "STOP HERE", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 6, Color(0.05, 0.1, 0.05))
		draw_string(font, at, "STOP HERE", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
