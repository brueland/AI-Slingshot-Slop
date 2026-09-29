class_name DistanceChart
extends Control
## A small line chart of the most recent run distances (oldest on the left, newest on the right).

var values: Array[float] = []


## Chart points for `data` inside a box of `box_size`: x spread evenly across the width, y from the bottom (0)
## up to the top (the largest value).
static func chart_points(data: Array, box_size: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	if data.is_empty():
		return out
	var top := 0.0
	for v in data:
		top = maxf(top, float(v))
	if top <= 0.0:
		top = 1.0
	var step := box_size.x / maxf(1.0, data.size() - 1.0)
	for i in data.size():
		out.append(Vector2(i * step, box_size.y - float(data[i]) / top * box_size.y))
	return out


func _ready() -> void:
	custom_minimum_size = Vector2(360, 120)


func set_values(new_values: Array) -> void:
	values.clear()
	for v in new_values:
		values.append(float(v))
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.3))
	var points := chart_points(values, size)
	if points.size() >= 2:
		draw_polyline(points, Color(1.0, 0.85, 0.3), 3.0, true)
	for p in points:
		draw_circle(p, 4.0, Color.WHITE)
