---
id: 126-keyboard-aim
status: ready
tests: [tests/acceptance/test_126_keyboard_aim.gd]
files: [scripts/game/slingshot.gd]
---

# Keyboard aiming

The slingshot can be aimed with the keyboard: the arrow keys start aiming and change the angle (up/down,
2 degrees) and the power (left/right, 5%); Enter launches with that pull. main.gd does not change.

**`scripts/game/slingshot.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. (Edit 4 adds two functions above `cancel_drag()` and one line as the first line of `cancel_drag()`.)

Edit 1 - SEARCH:
```gdscript
const AIM_LINE_COLOR := Color(1, 1, 1, 0.55)
```
REPLACE:
```gdscript
const AIM_LINE_COLOR := Color(1, 1, 1, 0.55)
const KEY_ANGLE_STEP: float = 2.0
const KEY_POWER_STEP: float = 0.05
```

Edit 2 - SEARCH:
```gdscript
var last_pull: Vector2 = Vector2.ZERO
```
REPLACE:
```gdscript
var last_pull: Vector2 = Vector2.ZERO
var key_angle: float = 45.0
var key_power: float = 0.8
var key_aiming: bool = false
```

Edit 3 - SEARCH:
```gdscript
		if repeat_last_shot():
			get_viewport().set_input_as_handled()
```
REPLACE:
```gdscript
		if repeat_last_shot():
			get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and key_aim(event.keycode):
		get_viewport().set_input_as_handled()
```

Edit 4 - SEARCH:
```gdscript
func cancel_drag() -> void:
```
REPLACE:
```gdscript
## The pull for the keyboard aim: key_angle degrees up, key_power (0..1) of the full pull.
func key_pull() -> Vector2:
	var r := deg_to_rad(key_angle)
	return Vector2(-cos(r), sin(r)) * max_pull * key_power


## Keyboard aiming: the arrow keys start aiming and change the angle (up/down) and power (left/right); Enter
## launches. Returns true when the key was used.
func key_aim(keycode: int) -> bool:
	if not enabled:
		return false
	match keycode:
		KEY_UP:
			key_angle = clampf(key_angle + KEY_ANGLE_STEP, 5.0, 85.0)
		KEY_DOWN:
			key_angle = clampf(key_angle - KEY_ANGLE_STEP, 5.0, 85.0)
		KEY_RIGHT:
			key_power = clampf(key_power + KEY_POWER_STEP, 0.1, 1.0)
		KEY_LEFT:
			key_power = clampf(key_power - KEY_POWER_STEP, 0.1, 1.0)
		KEY_ENTER, KEY_KP_ENTER:
			if not key_aiming:
				return false
			key_aiming = false
			dragging = true
			pull = key_pull()
			release()
			return true
		_:
			return false
	key_aiming = true
	dragging = true
	pull = key_pull()
	queue_redraw()
	return true


func cancel_drag() -> void:
	key_aiming = false
```

## Acceptance criteria
- Arrows pull the band to `key_pull()` (angle 5-85 degrees, power 0.1-1.0); Enter launches it like a mouse release.
- Keys do nothing while the slingshot is disabled; other keys are not used.
