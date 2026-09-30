class_name WindSock
extends Node2D
## A striped windsock on a pole near the slingshot. It points the way the roguelike wind blows (right for a
## tailwind, left for a headwind) and droops when there is no wind. Decoration only.

const POLE_M := Vector2(8.0, 0.0)
const POLE_PX: float = 56.0

var direction: float = 0.0
var time: float = 0.0


## 1.0 for a tailwind, -1.0 for a headwind, 0.0 for any other weather.
static func direction_for(weather_id: String) -> float:
	match weather_id:
		"tailwind":
			return 1.0
		"headwind":
			return -1.0
	return 0.0


func set_weather(weather_id: String) -> void:
	direction = direction_for(weather_id)
	queue_redraw()


func advance(delta: float) -> void:
	time += delta
	queue_redraw()


func _process(delta: float) -> void:
	advance(delta)


## Where the sock's tip is, relative to the top of the pole: straight out with the wind, hanging down without it.
func tip_offset() -> Vector2:
	var flap := sin(time * 6.0) * 2.0
	if direction == 0.0:
		return Vector2(4.0 + flap * 0.5, 26.0)
	return Vector2(direction * 30.0, 4.0 + flap)


func _draw() -> void:
	var base := WorldView.world_to_screen(POLE_M)
	var top := base + Vector2(0, -POLE_PX)
	draw_line(base, top, Color(0.85, 0.85, 0.85), 3.0)
	var along := tip_offset() / 4.0
	var side := along.orthogonal().normalized() * 6.0
	for k in 4:
		var a := top + along * k
		var b := top + along * (k + 1)
		var w := 1.0 - k * 0.15
		var color := Color(1.0, 0.45, 0.2) if k % 2 == 0 else Color.WHITE
		draw_colored_polygon(PackedVector2Array([a - side * w, a + side * w, b + side * (w - 0.15), b - side * (w - 0.15)]), color)
