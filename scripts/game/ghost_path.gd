class_name GhostPath
extends Node2D
## A faint dotted line along the best run so far (classic mode), so the player can see the path to beat.

const MAX_POINTS: int = 200
const DOT_COLOR := Color(1, 1, 1, 0.35)

var points: PackedVector2Array = PackedVector2Array()


## A saveable copy of a flight path: about MAX_POINTS [x, y] pairs (plus the last point), rounded to centimeters.
static func pack(path: PackedVector2Array) -> Array:
	var out: Array = []
	if path.is_empty():
		return out
	var every := maxi(1, ceili(path.size() / float(MAX_POINTS)))
	for i in range(0, path.size(), every):
		out.append([snappedf(path[i].x, 0.01), snappedf(path[i].y, 0.01)])
	if (path.size() - 1) % every != 0:
		var last := path[path.size() - 1]
		out.append([snappedf(last.x, 0.01), snappedf(last.y, 0.01)])
	return out


static func unpack(data: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for item in data:
		if item is Array and item.size() == 2:
			out.append(Vector2(float(item[0]), float(item[1])))
	return out


func set_points(world_points: PackedVector2Array) -> void:
	points = world_points
	queue_redraw()


func _draw() -> void:
	for p in points:
		draw_circle(WorldView.world_to_screen(p + Vector2(0.0, Balance.PROJECTILE_RADIUS)), 2.5, DOT_COLOR)
