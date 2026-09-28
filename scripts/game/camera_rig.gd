class_name CameraRig
extends Camera2D
## Keeps the projectile in view: target 25% left of center, ground near the bottom of the screen.

var follow_speed: float = 5.0
var view_size: Vector2 = Vector2(1280, 720)


static func desired_position(target: Vector2, view: Vector2) -> Vector2:
	var ground_view_y := -view.y * 0.5 + 100.0
	return Vector2(target.x + view.x * 0.25, minf(ground_view_y, target.y + view.y * 0.2))


func follow(target: Vector2, delta: float) -> void:
	position = position.lerp(desired_position(target, view_size), clampf(delta * follow_speed, 0.0, 1.0))


func snap_to(target: Vector2) -> void:
	position = desired_position(target, view_size)
