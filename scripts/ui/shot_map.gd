class_name ShotMap
extends Control
## A small drawing of the shot on the results screen: the flight path over the ground, stretched to fit the box.

const MAP_SIZE := Vector2(380, 70)
const PATH_COLOR := Color(1.0, 0.9, 0.4)
const GROUND_COLOR := Color(0.35, 0.6, 0.3)

var points: PackedVector2Array = PackedVector2Array()
var far: float = 1.0
var high: float = 1.0


func _ready() -> void:
	custom_minimum_size = MAP_SIZE


## The shot's path in world meters (RunSession.path).
func set_path(world_points: PackedVector2Array) -> void:
	points = world_points
	far = 1.0
	high = 1.0
	for p in points:
		far = maxf(far, p.x)
		high = maxf(high, p.y)
	queue_redraw()


## Where a world point is drawn inside the box: x from 0 to the farthest point, y from the ground to the highest.
func map_point(p: Vector2) -> Vector2:
	return Vector2(5.0 + p.x / far * (MAP_SIZE.x - 10.0), MAP_SIZE.y - 5.0 - p.y / high * (MAP_SIZE.y - 10.0))


func _draw() -> void:
	draw_line(Vector2(0, MAP_SIZE.y - 5.0), Vector2(MAP_SIZE.x, MAP_SIZE.y - 5.0), GROUND_COLOR, 2.0)
	if points.size() < 2:
		return
	var drawn := PackedVector2Array()
	for p in points:
		drawn.append(map_point(p))
	draw_polyline(drawn, PATH_COLOR, 2.0)
	draw_circle(drawn[drawn.size() - 1], 4.0, PATH_COLOR)
