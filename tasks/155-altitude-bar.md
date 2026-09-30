---
id: 155-altitude-bar
status: ready
tests: [tests/acceptance/test_155_altitude_bar.gd]
files: [scripts/ui/altitude_bar.gd, scripts/ui/hud.gd]
---

# Height bar

A thin vertical bar on the HUD (under the boosts) fills up as the alien climbs, full at 60 m.

**1. Create the file `scripts/ui/altitude_bar.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name AltitudeBar
extends Control
## A thin vertical bar on the HUD that fills up with the alien's height (full at FULL_HEIGHT_M).

const FULL_HEIGHT_M: float = 60.0
const BAR_SIZE := Vector2(12, 160)

var value: float = 0.0


func _ready() -> void:
	custom_minimum_size = BAR_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_height(height_m: float) -> void:
	value = clampf(height_m / FULL_HEIGHT_M, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, BAR_SIZE), Color(0, 0, 0, 0.35))
	var h := BAR_SIZE.y * value
	draw_rect(Rect2(Vector2(0, BAR_SIZE.y - h), Vector2(BAR_SIZE.x, h)), Color(0.5, 0.85, 1.0, 0.9))
```

**2. `scripts/ui/hud.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var hint_label: Label
```
REPLACE:
```gdscript
var hint_label: Label
var altitude_bar: AltitudeBar
```

Edit 2 - SEARCH:
```gdscript
	boosts_label.add_theme_font_size_override("font_size", 22)
```
REPLACE:
```gdscript
	boosts_label.add_theme_font_size_override("font_size", 22)
	
	altitude_bar = AltitudeBar.new()
	left_container.add_child(altitude_bar)
```

Edit 3 - SEARCH:
```gdscript
	boosts_label.text = "Boosts: %d" % boosts
```
REPLACE:
```gdscript
	boosts_label.text = "Boosts: %d" % boosts
	altitude_bar.set_height(height)
```

## Acceptance criteria
- `set_height(h)` sets `value` to h / 60 clamped to 0..1; the HUD updates it every flight frame; it is on screen.
