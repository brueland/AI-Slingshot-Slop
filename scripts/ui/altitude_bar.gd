class_name AltitudeBar
extends Control
## A thin vertical bar on the HUD that fills up with the alien's height (full at FULL_HEIGHT_M).

const FULL_HEIGHT_M: float = 60.0
const BAR_SIZE := Vector2(12, 160)

var value: float = 0.0


func _ready() -> void:
	custom_minimum_size = BAR_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_height(height_m: float) -> void:
	value = clampf(height_m / FULL_HEIGHT_M, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, BAR_SIZE), Color(0, 0, 0, 0.35))
	var h := BAR_SIZE.y * value
	draw_rect(Rect2(Vector2(0, BAR_SIZE.y - h), Vector2(BAR_SIZE.x, h)), Color(0.5, 0.85, 1.0, 0.9))
