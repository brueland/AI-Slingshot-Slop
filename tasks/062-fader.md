---
id: 062-fader
status: ready
tests: [tests/acceptance/test_062_fader.gd]
files: [scripts/ui/fader.gd, scripts/game/main.gd]
---

# Screen fades between screens

**1. Create `scripts/ui/fader.gd`:** a black overlay on its own top layer that fades out after each screen
change.
```gdscript
class_name Fader
extends CanvasLayer
## A black screen that fades out after each screen change, so switches feel smooth. Never blocks input.

const DEFAULT_DURATION: float = 0.3

var rect: ColorRect
var duration: float = DEFAULT_DURATION
var time_left: float = 0.0


func _ready() -> void:
	layer = 10
	rect = ColorRect.new()
	rect.color = Color(0, 0, 0, 0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(rect)


func _process(delta: float) -> void:
	advance(delta)


func flash(fade_time: float = DEFAULT_DURATION) -> void:
	duration = maxf(fade_time, 0.01)
	time_left = duration
	rect.color.a = 1.0


func advance(delta: float) -> void:
	if time_left <= 0.0:
		return
	time_left = maxf(0.0, time_left - delta)
	rect.color.a = time_left / duration


func alpha() -> float:
	return rect.color.a
```

**2. `scripts/game/main.gd`** (keep changes small):
- `var fader: Fader`; in `_ready()`, create it and `add_child(fader)` **before** `_build_ui()` is called.
- Flash on every state change except the launch (the flight must start instantly):
  ```gdscript
  func _on_state_changed(new_state: int) -> void:
  	if new_state != State.FLIGHT:
  		fader.flash()
  	_update_ui()
  ```

## Acceptance criteria
- The fader is layer 10, covers the screen, ignores the mouse, starts invisible, and fades 1 -> 0 over its duration.
- Title -> aim and flight -> results fade; aim -> flight does not.
