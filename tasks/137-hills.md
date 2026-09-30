---
id: 137-hills
status: ready
tests: [tests/acceptance/test_137_hills.gd]
files: [scripts/game/hills.gd, scripts/game/background.gd]
---

# Rolling hills

Milestone 16 adds scenery and whimsy. Soft rolling hills sit far behind the meadow, in their own background
layer that scrolls slower than the world.

**1. Create the file `scripts/game/hills.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name Hills
extends Node2D
## Soft rolling hills far behind the meadow, in their own background layer that scrolls slowly.

const WIDTH: float = 1800.0
const FAR_COLOR := Color(0.55, 0.7, 0.55)
const NEAR_COLOR := Color(0.45, 0.65, 0.45)


## The top edge of a band of hills: a point every 60 px across WIDTH, `base` to `base + height` px above the ground.
static func outline(base: float, height: float, phase: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	var x := -WIDTH / 2.0
	while x <= WIDTH / 2.0:
		out.append(Vector2(x, -base - height * (0.5 + 0.5 * sin(x / 170.0 + phase))))
		x += 60.0
	return out


func _draw() -> void:
	_draw_band(140.0, 90.0, 0.0, FAR_COLOR)
	_draw_band(60.0, 60.0, 2.0, NEAR_COLOR)


func _draw_band(base: float, height: float, phase: float, color: Color) -> void:
	var poly := outline(base, height, phase)
	poly.append(Vector2(WIDTH / 2.0, 40.0))
	poly.append(Vector2(-WIDTH / 2.0, 40.0))
	draw_colored_polygon(poly, color)
```

**`scripts/game/background.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var star_field: StarField
```
REPLACE:
```gdscript
var star_field: StarField
var hills_layer: Parallax2D
var hills: Hills
```

Edit 2 - SEARCH:
```gdscript
	add_child(stars_layer)
```
REPLACE:
```gdscript
	add_child(stars_layer)
	
	# Hills: a separate layer (not in `layers`) that scrolls slower than the world
	hills_layer = Parallax2D.new()
	hills_layer.scroll_scale = Vector2(0.3, 1.0)
	hills_layer.repeat_size = Vector2(Hills.WIDTH, 0)
	hills_layer.repeat_times = 3
	hills = Hills.new()
	hills_layer.add_child(hills)
	add_child(hills_layer)
```

## Acceptance criteria
- `Hills.outline()` gives a point every 60 px across 1800 px; the background has a separate `hills_layer` (scroll 0.3); `layers` still has 2 entries.
