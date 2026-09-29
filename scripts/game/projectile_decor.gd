class_name ProjectileDecor
extends Node2D
## Drawn on top of the alien and always upright (top_level, so it does not roll with the sprite): the hat.
## Coordinates are screen pixels around the alien's center; the alien is 24 px wide (head top at y = -12).

const HAT_Y: float = -10.0

var hat: String = "none"
var spin: float = 0.0


func _ready() -> void:
	top_level = true


func _process(delta: float) -> void:
	spin = fmod(spin + delta * 18.0, TAU)
	if hat == "propeller":
		queue_redraw()


func set_hat(id: String) -> void:
	hat = id if not Hats.get_def(id).is_empty() else "none"
	queue_redraw()


## The upper half of a circle (a dome) as a polygon.
static func dome(center: Vector2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 13:
		var a := PI + PI * i / 12.0
		points.append(center + Vector2(cos(a), sin(a)) * radius)
	return points


func _draw() -> void:
	var y := HAT_Y
	match hat:
		"party":
			draw_colored_polygon(PackedVector2Array([Vector2(-7, y), Vector2(7, y), Vector2(0, y - 18)]), Color(0.95, 0.3, 0.6))
			draw_line(Vector2(-4.5, y - 6), Vector2(4.5, y - 6), Color(1.0, 0.9, 0.2), 2.0)
			draw_circle(Vector2(0, y - 18), 3.0, Color(1.0, 0.9, 0.2))
		"propeller":
			draw_colored_polygon(dome(Vector2(0, y + 1), 8.0), Color(0.2, 0.5, 0.95))
			draw_line(Vector2(0, y - 7), Vector2(0, y - 11), Color(0.3, 0.3, 0.3), 2.0)
			var blade := Vector2(cos(spin), sin(spin) * 0.3) * 9.0
			draw_line(Vector2(0, y - 11) - blade, Vector2(0, y - 11) + blade, Color(1.0, 0.3, 0.25), 3.0)
		"chef":
			draw_rect(Rect2(-7, y - 5, 14, 5), Color(0.95, 0.95, 0.95))
			for c in [Vector2(-5, y - 9), Vector2(0, y - 12), Vector2(5, y - 9)]:
				draw_circle(c, 5.0, Color.WHITE)
		"top_hat":
			draw_rect(Rect2(-11, y - 2, 22, 3), Color(0.1, 0.1, 0.12))
			draw_rect(Rect2(-7, y - 16, 14, 14), Color(0.1, 0.1, 0.12))
			draw_rect(Rect2(-7, y - 6, 14, 3), Color(0.8, 0.15, 0.2))
		"wizard":
			draw_colored_polygon(PackedVector2Array([Vector2(-9, y), Vector2(9, y), Vector2(4, y - 24)]), Color(0.45, 0.25, 0.75))
			draw_line(Vector2(-11, y), Vector2(11, y), Color(0.45, 0.25, 0.75), 3.0)
			draw_circle(Vector2(-2, y - 8), 1.5, Color(1.0, 0.9, 0.3))
			draw_circle(Vector2(3, y - 14), 1.5, Color(1.0, 0.9, 0.3))
		"crown":
			draw_colored_polygon(PackedVector2Array([Vector2(-9, y), Vector2(-9, y - 8), Vector2(-5, y - 4),
				Vector2(0, y - 11), Vector2(5, y - 4), Vector2(9, y - 8), Vector2(9, y)]), Color(1.0, 0.8, 0.15))
			draw_circle(Vector2(0, y - 3), 1.8, Color(0.9, 0.15, 0.2))
			draw_circle(Vector2(-5, y - 2), 1.3, Color(0.2, 0.4, 0.95))
			draw_circle(Vector2(5, y - 2), 1.3, Color(0.2, 0.4, 0.95))
