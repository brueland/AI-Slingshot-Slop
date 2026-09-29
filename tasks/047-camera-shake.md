---
id: 047-camera-shake
status: ready
tests: [tests/acceptance/test_047_camera_shake.gd]
files: [scripts/game/camera_rig.gd, scripts/game/main.gd]
---

# Camera shake on springs and hard landings

**1. `scripts/game/camera_rig.gd`** (keep `desired_position`, `follow`, `snap_to`). The shake moves the
camera's `offset`, never its `position`, and uses a seeded RNG so it is deterministic:
```gdscript
var shake_strength: float = 0.0
var shake_duration: float = 0.0
var shake_time_left: float = 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 12345


func _process(delta: float) -> void:
	update_shake(delta)


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
```

**2. `scripts/game/main.gd`:** in `_on_spring_hit` add `camera.shake(10.0, 0.35)`. In `_on_bounced`, rename the
parameter to `impact_speed` and add `if impact_speed >= 8.0: camera.shake(4.0, 0.2)`.

## Acceptance criteria
- A shake moves the offset (fading with time) and ends at zero; two cameras shake identically.
- Springs and bounces of 8 m/s or more shake main's camera; softer bounces don't.
