class_name SkyBalloons
extends Node2D
## Three hot-air balloons far off in the sky, drifting slowly with the breeze and bobbing. Decoration only.

const START_M: Array[Vector2] = [Vector2(140.0, 38.0), Vector2(330.0, 55.0), Vector2(560.0, 30.0)]
const COLORS: Array[Color] = [Color(0.95, 0.4, 0.35), Color(0.4, 0.75, 0.45), Color(0.55, 0.5, 0.95)]
const DRIFT_MPS: float = 0.6

var time: float = 0.0


## Where balloon `index` is right now, in world meters (x along the course, y up).
func balloon_position_m(index: int) -> Vector2:
	var start := START_M[index]
	return Vector2(start.x + time * DRIFT_MPS, start.y + sin(time * 0.7 + index * 2.0) * 1.5)


func advance(delta: float) -> void:
	time += delta
	queue_redraw()


func _process(delta: float) -> void:
	advance(delta)


func _draw() -> void:
	for i in START_M.size():
		var c := WorldView.world_to_screen(balloon_position_m(i))
		draw_circle(c, 22.0, COLORS[i])
		draw_colored_polygon(PackedVector2Array([c + Vector2(-19, 10), c + Vector2(19, 10), c + Vector2(7, 30), c + Vector2(-7, 30)]), COLORS[i])
		draw_line(c + Vector2(-20, -4), c + Vector2(20, -4), Color(1, 1, 1, 0.5), 3.0)
		draw_line(c + Vector2(-6, 30), c + Vector2(-5, 40), Color(0.3, 0.25, 0.2), 1.0)
		draw_line(c + Vector2(6, 30), c + Vector2(5, 40), Color(0.3, 0.25, 0.2), 1.0)
		draw_rect(Rect2(c + Vector2(-6, 40), Vector2(12, 9)), Color(0.55, 0.35, 0.2))
