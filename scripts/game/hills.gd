class_name Hills
extends Node2D
## Soft rolling hills far behind the meadow, in their own background layer that scrolls slowly.

const WIDTH: float = 1800.0
const FAR_COLOR := Color(0.55, 0.7, 0.55)
const NEAR_COLOR := Color(0.45, 0.65, 0.45)


## The top edge of a band of hills: a point every 60 px across WIDTH, `base` to `base + height` px above the ground.
static func outline(base: float, height: float, phase: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	var x := -WIDTH / 2.0
	while x <= WIDTH / 2.0:
		out.append(Vector2(x, -base - height * (0.5 + 0.5 * sin(x / 170.0 + phase))))
		x += 60.0
	return out


func _draw() -> void:
	_draw_band(140.0, 90.0, 0.0, FAR_COLOR)
	_draw_band(60.0, 60.0, 2.0, NEAR_COLOR)


func _draw_band(base: float, height: float, phase: float, color: Color) -> void:
	var poly := outline(base, height, phase)
	poly.append(Vector2(WIDTH / 2.0, 40.0))
	poly.append(Vector2(-WIDTH / 2.0, 40.0))
	draw_colored_polygon(poly, color)
