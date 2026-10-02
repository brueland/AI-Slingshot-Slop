---
id: 286-wrong-way-signs
status: ready
tests: [tests/acceptance/test_286_wrong_way_signs.gd, tests/acceptance/test_249_endless_ground.gd]
files: [scripts/game/wrong_way.gd, scripts/game/world_builder.gd, scripts/game/world_view.gd]
---

# WRONG WAY

Behind the slingshot `WrongWay` (a new script) draws three red WRONG WAY signs pointing back to the course (at
-25, -55 and -85 m) and the giant brick wall at `Balance.WALL_X` (60 m tall). WorldBuilder adds it right after the
ground, and the ground is drawn to 175 m behind the slingshot so it reaches past the wall. One older test is
updated for the longer ground.

**1. Create the file `scripts/game/wrong_way.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
class_name WrongWay
extends Node2D
## Behind the slingshot: red "WRONG WAY" signs pointing back to the course and, at Balance.WALL_X, a giant brick wall
## the alien bounces off (FlightSim does the bouncing).

const SIGNS_M: Array[float] = [-25.0, -55.0, -85.0]
const WALL_HEIGHT_M: float = 60.0
const WALL_THICK_M: float = 4.0
const BRICK := Color(0.72, 0.3, 0.22)
const MORTAR := Color(0.86, 0.8, 0.72)


func _draw() -> void:
	var font := UiTheme.game_font(800)
	for x in SIGNS_M:
		var base := WorldView.ground_point(x)
		draw_rect(Rect2(base + Vector2(-3, -70), Vector2(6, 70)), Color(0.45, 0.3, 0.18))
		draw_rect(Rect2(base + Vector2(-68, -108), Vector2(136, 40)), Color.WHITE)
		draw_rect(Rect2(base + Vector2(-65, -105), Vector2(130, 34)), Color(0.85, 0.15, 0.12))
		draw_string(font, base + Vector2(-56, -81), "WRONG WAY", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
		draw_colored_polygon(PackedVector2Array([base + Vector2(70, -98), base + Vector2(90, -88), base + Vector2(70, -78)]), Color(0.85, 0.15, 0.12))
	var right := WorldView.world_to_screen(Vector2(Balance.WALL_X, 0.0))
	var w := WALL_THICK_M * Balance.PIXELS_PER_METER
	var h := WALL_HEIGHT_M * Balance.PIXELS_PER_METER
	var left := right.x - w
	draw_rect(Rect2(left, right.y - h, w, h + 8), MORTAR)
	var row := 0
	var y := right.y + 8
	while y > right.y - h:
		var x := left - (16.0 if row % 2 == 1 else 0.0)
		while x < right.x:
			var a := maxf(x, left) + 1.0
			var b := minf(x + 32.0, right.x) - 1.0
			if b > a:
				draw_rect(Rect2(a, y - 15, b - a, 14), BRICK)
			x += 32.0
		y -= 16.0
		row += 1
```

**2. `scripts/game/world_builder.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	main.world_view = WorldView.new()
	main.add_child(main.world_view)
```
REPLACE:
```gdscript
	main.world_view = WorldView.new()
	main.add_child(main.world_view)
	main.add_child(WrongWay.new())
```

**3. `scripts/game/world_view.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE changes the limit behind the slingshot from 105 m to 175 m (and the start values); nothing else changes.

Edit 1 - SEARCH:
```gdscript
var drawn_from_m: float = -105.0
var drawn_to_m: float = 730.0
```
REPLACE:
```gdscript
var drawn_from_m: float = -175.0
var drawn_to_m: float = 660.0
```

Edit 2 - SEARCH:
```gdscript
## on a multiple of SNAP_M, and never more than 105 m behind the slingshot.
```
REPLACE:
```gdscript
## on a multiple of SNAP_M, and never more than 175 m behind the slingshot (the brick wall is at 120 m).
```

Edit 3 - SEARCH:
```gdscript
	var from := maxf(floorf((center_m - DRAW_SPAN_M) / SNAP_M) * SNAP_M, -105.0)
```
REPLACE:
```gdscript
	var from := maxf(floorf((center_m - DRAW_SPAN_M) / SNAP_M) * SNAP_M, -175.0)
```

## Acceptance criteria
- WorldBuilder adds a `WrongWay` after the WorldView; it draws the signs and the brick wall.
- `WorldView.span_around` never starts before -175 m.
