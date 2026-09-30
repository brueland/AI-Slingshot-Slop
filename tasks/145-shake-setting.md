---
id: 145-shake-setting
status: ready
tests: [tests/acceptance/test_145_shake_setting.gd]
files: [scripts/game/camera_rig.gd, scripts/core/progress.gd]
---

# Screen shake setting

Milestone 17 adds options and classic extras. Screen shake can be turned off: `CameraRig.shake_enabled`,
and `Progress.shake_on` (saved, on by default).

**1. `scripts/game/camera_rig.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. (Edit 2 adds two lines as the first lines of `shake()`.)

Edit 1 - SEARCH:
```gdscript
var shake_time_left: float = 0.0
```
REPLACE:
```gdscript
var shake_time_left: float = 0.0
var shake_enabled: bool = true
```

Edit 2 - SEARCH:
```gdscript
func shake(strength: float, duration: float) -> void:
```
REPLACE:
```gdscript
func shake(strength: float, duration: float) -> void:
	if not shake_enabled:
		return
```

**2. `scripts/core/progress.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. (Edit 3 adds one line right before the final `return p` of `from_dict()`.)

Edit 1 - SEARCH:
```gdscript
var rogue_history: Array = []
```
REPLACE:
```gdscript
var rogue_history: Array = []
var shake_on: bool = true
```

Edit 2 - SEARCH:
```gdscript
		"rogue_history": rogue_history.duplicate(true),
```
REPLACE:
```gdscript
		"rogue_history": rogue_history.duplicate(true),
		"shake_on": shake_on,
```

Edit 3 - SEARCH:
```gdscript
	return p
```
REPLACE:
```gdscript
	p.shake_on = bool(data.get("shake_on", true))
	return p
```

## Acceptance criteria
- With `shake_enabled` false, `shake()` does nothing.
- `Progress.shake_on` is true by default and saved.
