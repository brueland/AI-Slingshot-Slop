---
id: 140-kites
status: ready
tests: [tests/acceptance/test_140_kites.gd]
files: [scripts/game/kites.gd, scripts/game/world_builder.gd, scripts/game/main.gd]
---

# Kites

Three kites on long strings fly near the start, swaying in the breeze. Decoration only.

**1. Create the file `scripts/game/kites.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name Kites
extends Node2D
## Three kites on long strings near the start, swaying in the breeze. Decoration only.

const ANCHORS_M: Array[float] = [18.0, 45.0, 80.0]
const COLORS: Array[Color] = [Color(0.95, 0.35, 0.35), Color(0.35, 0.6, 0.95), Color(1.0, 0.8, 0.25)]

var time: float = 0.0


## Screen position of kite `index` right now.
func kite_position(index: int) -> Vector2:
	var sway := Vector2(4.0 + sin(time * 0.8 + index) * 1.5, 13.0 + index * 2.0 + sin(time * 1.3 + index) * 0.8)
	return WorldView.world_to_screen(Vector2(ANCHORS_M[index], 0.0) + sway)


func advance(delta: float) -> void:
	time += delta
	queue_redraw()


func _process(delta: float) -> void:
	advance(delta)


func _draw() -> void:
	for i in ANCHORS_M.size():
		var k := kite_position(i)
		var base := WorldView.world_to_screen(Vector2(ANCHORS_M[i], 0.0))
		draw_line(base, k + Vector2(0, 14), Color(1, 1, 1, 0.5), 1.0)
		draw_colored_polygon(PackedVector2Array([k + Vector2(0, -14), k + Vector2(10, 0), k + Vector2(0, 14), k + Vector2(-10, 0)]), COLORS[i])
		draw_line(k + Vector2(0, 14), k + Vector2(-6, 26), COLORS[i], 1.5)
```

**2. `scripts/game/world_builder.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	main.add_child(main.cows)
```
REPLACE:
```gdscript
	main.add_child(main.cows)
	main.kites = Kites.new()
	main.add_child(main.kites)
```

**3. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var cows: Cows
```
REPLACE:
```gdscript
var cows: Cows
var kites: Kites
```

## Acceptance criteria
- Kites sway over time, high above their anchors; main has `kites` behind the course items.
