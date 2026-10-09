class_name BalloonView
extends Node2D
## Draws the current shot's party balloons (bobbing ovals on strings). Popped balloons disappear.

const COLORS: Array[Color] = [Color(0.95, 0.3, 0.35), Color(0.3, 0.6, 0.95), Color(1.0, 0.8, 0.2),
	Color(0.5, 0.85, 0.4), Color(0.8, 0.45, 0.9)]

var points: Array[Vector2] = []
var shown: Array[bool] = []
## The hat each balloon carries ("" for none).
var hats: Array[String] = []
var bob: float = 0.0


func build(balloons: Balloons) -> void:
	points = balloons.points.duplicate()
	hats = balloons.hats.duplicate()
	shown.clear()
	for i in points.size():
		shown.append(true)
	queue_redraw()


## The shot's balloons grew (a long shot): show the new ones too.
func grow(balloons: Balloons) -> void:
	for i in range(points.size(), balloons.points.size()):
		points.append(balloons.points[i])
		hats.append(balloons.hats[i] if i < balloons.hats.size() else "")
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
	# only the balloons on screen are drawn
	var span := WorldView.visible_span(self, 4.0)
	for i in points.size():
		if not shown[i] or points[i].x < span.x or points[i].x > span.y:
			continue
		var c := screen_position(i)
		var color := COLORS[i % COLORS.size()]
		draw_line(c + Vector2(0, 17), c + Vector2(3, 40), Color(0.95, 0.95, 0.95, 0.8), 1.0)
		draw_colored_polygon(ellipse(c, 14.0, 18.0), color)
		draw_colored_polygon(PackedVector2Array([c + Vector2(-3, 20), c + Vector2(3, 20), c + Vector2(0, 16)]), color.darkened(0.2))
		draw_circle(c + Vector2(-5, -7), 3.5, Color(1, 1, 1, 0.45))
		if i < hats.size() and hats[i] != "":
			_draw_hat_tag(c + Vector2(3, 47), hats[i])


## A small hat hanging from a balloon's string: popping the balloon finds it.
func _draw_hat_tag(at: Vector2, id: String) -> void:
	match id:
		"cowboy":
			draw_colored_polygon(ellipse(at, 11.0, 2.5), Color(0.55, 0.33, 0.15))
			draw_rect(Rect2(at + Vector2(-5, -8), Vector2(10, 8)), Color(0.62, 0.38, 0.18))
		"viking":
			draw_circle(at + Vector2(0, -3), 6.0, Color(0.62, 0.64, 0.7))
			draw_line(at + Vector2(-5, -5), at + Vector2(-10, -12), Color(0.98, 0.95, 0.85), 3.0)
			draw_line(at + Vector2(5, -5), at + Vector2(10, -12), Color(0.98, 0.95, 0.85), 3.0)
		_:
			draw_circle(at + Vector2(0, -3), 6.0, Color(0.2, 0.7, 0.55))
			draw_circle(at + Vector2(0, -10), 2.5, Color(0.95, 0.4, 0.4))
