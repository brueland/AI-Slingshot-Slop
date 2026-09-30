---
id: 153-grazing
status: ready
tests: [tests/acceptance/test_153_grazing.gd]
files: [scripts/game/critters.gd]
---

# Grazing sheep

The sheep graze: now and then their heads dip down a few pixels.

**`scripts/game/critters.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edits 1-3 keep their SEARCH lines and add new ones; Edit 4 replaces the two head lines in `_draw()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var hop_left: Array[float] = []
```
REPLACE:
```gdscript
var hop_left: Array[float] = []
var time: float = 0.0
```

Edit 2 - SEARCH:
```gdscript
func advance(delta: float) -> void:
```
REPLACE:
```gdscript
func advance(delta: float) -> void:
	time += delta
	queue_redraw()
```

Edit 3 - SEARCH:
```gdscript
func _process(delta: float) -> void:
```
REPLACE:
```gdscript
## How far sheep `index` has lowered its head to graze right now (0-3 px).
func head_bob(index: int) -> float:
	return maxf(0.0, sin(time * 1.5 + index * 1.3)) * 3.0


func _process(delta: float) -> void:
```

Edit 4 - SEARCH:
```gdscript
		draw_circle(p + Vector2(12, -13), 4.0, FACE)
		draw_circle(p + Vector2(13, -14), 1.0, Color.WHITE)
```
REPLACE:
```gdscript
		draw_circle(p + Vector2(12, -13 + head_bob(i)), 4.0, FACE)
		draw_circle(p + Vector2(13, -14 + head_bob(i)), 1.0, Color.WHITE)
```

## Acceptance criteria
- `head_bob(i)` stays within 0-3 px and changes over time; the sheep redraw every frame.
