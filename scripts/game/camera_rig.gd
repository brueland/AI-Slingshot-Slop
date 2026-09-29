class_name CameraRig
extends Camera2D
## Keeps the projectile in view: target 25% left of center, ground near the bottom of the screen.

var follow_speed: float = 5.0
var view_size: Vector2 = Vector2(1280, 720)
var shake_strength: float = 0.0
var shake_duration: float = 0.0
var shake_time_left: float = 0.0
var _rng := RandomNumberGenerator.new()


static func desired_position(target: Vector2, view: Vector2) -> Vector2:
	var ground_view_y := -view.y * 0.5 + 100.0
	return Vector2(target.x + view.x * 0.25, minf(ground_view_y, target.y + view.y * 0.2))


func _ready() -> void:
	_rng.seed = 12345


func _process(delta: float) -> void:
	update_shake(delta)


func follow(target: Vector2, delta: float) -> void:
	position = position.lerp(desired_position(target, view_size), clampf(delta * follow_speed, 0.0, 1.0))


func snap_to(target: Vector2) -> void:
	position = desired_position(target, view_size)


func shake(strength: float, duration: float) -> void:
	shake_strength = strength
	shake_duration = maxf(duration, 0.001)
	shake_time_left = shake_duration


func is_shaking() -> bool:
	return shake_time_left > 0.0


func update_shake(delta: float) -> void:
	if shake_time_left <= 0.0:
		offset = Vector2.ZERO
		return
	shake_time_left = maxf(0.0, shake_time_left - delta)
	if shake_time_left <= 0.0:
		offset = Vector2.ZERO
		return
	var s := shake_strength * shake_time_left / shake_duration
	offset = Vector2(_rng.randf_range(-s, s), _rng.randf_range(-s, s))
