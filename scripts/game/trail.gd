class_name Trail
extends Line2D
## A fading line behind the flying projectile (the newest point is the brightest).

const MAX_POINTS: int = 30


func _ready() -> void:
	width = 8.0
	joint_mode = Line2D.LINE_JOINT_ROUND
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0.0))
	fade.set_color(1, Color(1, 1, 1, 0.7))
	gradient = fade


func add_trail_point(point: Vector2) -> void:
	add_point(point)
	while get_point_count() > MAX_POINTS:
		remove_point(0)


func clear_trail() -> void:
	clear_points()
