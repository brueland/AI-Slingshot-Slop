class_name RocketGauge
extends ProgressBar
## The HUD's rocket gauge: how much of the rocket is left this flight, in orange.


func _init() -> void:
	custom_minimum_size = Vector2(150, 10)
	max_value = 1.0
	step = 0.0
	show_percentage = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(1.0, 0.55, 0.1)
	fill.set_corner_radius_all(4)
	add_theme_stylebox_override("fill", fill)


## `seconds` of rocket left out of `full` (0 = no rocket: the gauge hides).
func show_fuel(seconds: float, full: float) -> void:
	visible = full > 0.0
	value = clampf(seconds / full, 0.0, 1.0) if full > 0.0 else 0.0
