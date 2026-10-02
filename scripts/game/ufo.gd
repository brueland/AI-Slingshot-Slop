class_name Ufo
extends Node2D
## Friendly UFOs hovering high above the course at a few distances. When the alien flies close to one, it switches on
## its beam and says hello. A new shot resets them.

const SPOTS_M: Array[float] = [180.0, 420.0, 750.0, 1100.0, 1600.0]
const HEIGHT_M: float = 22.0
const GREET_DISTANCE_PX: float = 220.0
const LINES: Array[String] = ["Hello, cousin!", "Nice flight!", "Take me to your leader!", "Beep boop!", "Wheee!"]

var greeted: Array[bool] = []
var target: Node2D
var time: float = 0.0


func _ready() -> void:
	reset()


func reset() -> void:
	greeted.clear()
	for i in SPOTS_M.size():
		greeted.append(false)
	queue_redraw()


## Screen position of UFO `index` right now (it drifts and bobs a little).
func ufo_position(index: int) -> Vector2:
	var drift := Vector2(sin(time * 1.5 + index) * 20.0, sin(time * 2.0 + index) * 6.0)
	return WorldView.world_to_screen(Vector2(SPOTS_M[index], HEIGHT_M)) + drift


## UFOs within GREET_DISTANCE_PX of a screen position say hello (once per shot). Returns how many did.
func greet_near(screen_position: Vector2) -> int:
	var count := 0
	for i in SPOTS_M.size():
		if not greeted[i] and ufo_position(i).distance_to(screen_position) <= GREET_DISTANCE_PX:
			greeted[i] = true
			count += 1
			var hello := FloatingText.new()
			hello.setup(LINES[i % LINES.size()], Color(0.6, 1.0, 0.6))
			hello.position = ufo_position(i) + Vector2(-60.0, -50.0)
			add_child(hello)
	return count


func advance(delta: float) -> void:
	time += delta
	if target != null:
		greet_near(target.position)
	queue_redraw()


func _process(delta: float) -> void:
	advance(delta)


func _draw() -> void:
	for i in SPOTS_M.size():
		var p := ufo_position(i)
		# the tractor beam down to the ground (TractorBeams pulls the alien up inside it); brighter after hello
		var foot := WorldView.world_to_screen(Vector2(TractorBeams.SPOTS_M[i], 0.0))
		var top := TractorBeams.TOP_HALF_WIDTH * Balance.PIXELS_PER_METER
		var bottom := TractorBeams.BOTTOM_HALF_WIDTH * Balance.PIXELS_PER_METER
		draw_colored_polygon(PackedVector2Array([p + Vector2(-top, 4), p + Vector2(top, 4), foot + Vector2(bottom, 0), foot + Vector2(-bottom, 0)]),
			Color(1.0, 1.0, 0.6, 0.25 if greeted[i] else 0.12))
		draw_circle(p + Vector2(0, -6), 9.0, Color(0.6, 0.85, 1.0, 0.9))
		draw_colored_polygon(BalloonView.ellipse(p, 26.0, 7.0), Color(0.55, 0.55, 0.65))
		for k in 3:
			var on := int(time * 4.0 + k) % 3 == 0
			draw_circle(p + Vector2(-14 + k * 14, 1), 2.5, Color(1.0, 0.4, 0.4) if on else Color(1.0, 0.9, 0.4))
