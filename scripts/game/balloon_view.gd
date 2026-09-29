class_name BalloonView
extends Node2D
## Draws the current shot's party balloons (bobbing ovals on strings). Popped balloons disappear.

const COLORS: Array[Color] = [Color(0.95, 0.3, 0.35), Color(0.3, 0.6, 0.95), Color(1.0, 0.8, 0.2),
	Color(0.5, 0.85, 0.4), Color(0.8, 0.45, 0.9)]

var points: Array[Vector2] = []
var shown: Array[bool] = []
var bob: float = 0.0


func build(balloons: Balloons) -> void:
	points = balloons.points.duplicate()
	shown.clear()
	for i in points.size():
		shown.append(true)
	queue_redraw()


func pop(index: int) -> void:
	if index >= 0 and index < shown.size():
		shown[index] = false
		queue_redraw()


func visible_count() -> int:
	return shown.count(true)


## Screen position of balloon `index` right now (it bobs up and down a little).
func screen_position(index: int) -> Vector2:
	return WorldView.world_to_screen(points[index]) + Vector2(0.0, sin(bob + index) * 3.0)


static func ellipse(center: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		out.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	return out


func _process(delta: float) -> void:
	bob = fmod(bob + delta * 2.0, TAU)
	if not points.is_empty():
		queue_redraw()


func _draw() -> void:
	for i in points.size():
		if not shown[i]:
			continue
		var c := screen_position(i)
		var color := COLORS[i % COLORS.size()]
		draw_line(c + Vector2(0, 17), c + Vector2(3, 40), Color(0.95, 0.95, 0.95, 0.8), 1.0)
		draw_colored_polygon(ellipse(c, 14.0, 18.0), color)
		draw_colored_polygon(PackedVector2Array([c + Vector2(-3, 20), c + Vector2(3, 20), c + Vector2(0, 16)]), color.darkened(0.2))
		draw_circle(c + Vector2(-5, -7), 3.5, Color(1, 1, 1, 0.45))
