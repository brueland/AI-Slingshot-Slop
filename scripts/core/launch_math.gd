class_name LaunchMath
extends RefCounted
## Converts a slingshot pull (screen pixels, y down) into a launch velocity (world m/s, y up).


static func clamp_pull(pull: Vector2, max_pull: float) -> Vector2:
	return pull.limit_length(max_pull)


static func velocity_from_pull(pull: Vector2, max_pull: float, max_speed: float) -> Vector2:
	if max_pull <= 0.0 or pull == Vector2.ZERO:
		return Vector2.ZERO
	
	var p: Vector2 = clamp_pull(pull, max_pull)
	var strength: float = p.length() / max_pull
	var direction: Vector2 = Vector2(-p.x, p.y).normalized()
	
	return direction * strength * max_speed
