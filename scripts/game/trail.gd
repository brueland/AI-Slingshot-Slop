class_name Trail
extends Line2D
## A fading line behind the flying projectile (the newest point is the brightest).

const MAX_POINTS: int = 30

var style: String = "none"


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


## The trail's colors follow the hat: rainbow (party hat), purple (wizard hat), gold (crown), white otherwise.
func set_style(hat_id: String) -> void:
	style = hat_id
	var fade := Gradient.new()
	match hat_id:
		"party":
			fade.set_color(0, Color(1.0, 0.3, 0.3, 0.0))
			fade.set_color(1, Color(0.7, 0.4, 1.0, 0.8))
			fade.add_point(0.33, Color(1.0, 0.85, 0.2, 0.4))
			fade.add_point(0.66, Color(0.3, 0.8, 1.0, 0.6))
		"wizard":
			fade.set_color(0, Color(0.7, 0.4, 1.0, 0.0))
			fade.set_color(1, Color(0.7, 0.4, 1.0, 0.8))
		"crown":
			fade.set_color(0, Color(1.0, 0.85, 0.3, 0.0))
			fade.set_color(1, Color(1.0, 0.85, 0.3, 0.8))
		_:
			fade.set_color(0, Color(1, 1, 1, 0.0))
			fade.set_color(1, Color(1, 1, 1, 0.7))
	gradient = fade


func clear_trail() -> void:
	clear_points()
