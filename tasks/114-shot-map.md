---
id: 114-shot-map
status: ready
tests: [tests/acceptance/test_114_shot_map.gd]
files: [scripts/ui/shot_map.gd, scripts/ui/results_panel.gd, scripts/game/main.gd]
---

# A map of the shot on the results screen

Milestone 13 adds features and whimsy. The results screen shows a small drawing of the shot just flown: the flight
path over the ground, stretched to fit a 380 x 70 box.

**1. Create the file `scripts/ui/shot_map.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name ShotMap
extends Control
## A small drawing of the shot on the results screen: the flight path over the ground, stretched to fit the box.

const MAP_SIZE := Vector2(380, 70)
const PATH_COLOR := Color(1.0, 0.9, 0.4)
const GROUND_COLOR := Color(0.35, 0.6, 0.3)

var points: PackedVector2Array = PackedVector2Array()
var far: float = 1.0
var high: float = 1.0


func _ready() -> void:
	custom_minimum_size = MAP_SIZE


## The shot's path in world meters (RunSession.path).
func set_path(world_points: PackedVector2Array) -> void:
	points = world_points
	far = 1.0
	high = 1.0
	for p in points:
		far = maxf(far, p.x)
		high = maxf(high, p.y)
	queue_redraw()


## Where a world point is drawn inside the box: x from 0 to the farthest point, y from the ground to the highest.
func map_point(p: Vector2) -> Vector2:
	return Vector2(5.0 + p.x / far * (MAP_SIZE.x - 10.0), MAP_SIZE.y - 5.0 - p.y / high * (MAP_SIZE.y - 10.0))


func _draw() -> void:
	draw_line(Vector2(0, MAP_SIZE.y - 5.0), Vector2(MAP_SIZE.x, MAP_SIZE.y - 5.0), GROUND_COLOR, 2.0)
	if points.size() < 2:
		return
	var drawn := PackedVector2Array()
	for p in points:
		drawn.append(map_point(p))
	draw_polyline(drawn, PATH_COLOR, 2.0)
	draw_circle(drawn[drawn.size() - 1], 4.0, PATH_COLOR)
```

**2. `scripts/ui/results_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var hats_label: Label
```
REPLACE:
```gdscript
var hats_label: Label
var shot_map: ShotMap
```

Edit 2 - SEARCH:
```gdscript
	quip_label.add_theme_color_override("font_color", Color(0.75, 1.0, 0.85))
	vbox.add_child(quip_label)
```
REPLACE:
```gdscript
	quip_label.add_theme_color_override("font_color", Color(0.75, 1.0, 0.85))
	vbox.add_child(quip_label)
	
	shot_map = ShotMap.new()
	vbox.add_child(shot_map)
```

Edit 3 - SEARCH:
```gdscript
	quip_label.text = "\"%s\"" % Quips.pick(said)
```
REPLACE:
```gdscript
	quip_label.text = "\"%s\"" % Quips.pick(said)
	var path: PackedVector2Array = result.get("path", PackedVector2Array())
	shot_map.set_path(path)
```

**3. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	last_result["new_best"] = last_result["distance"] > previous_best
```
REPLACE:
```gdscript
	last_result["new_best"] = last_result["distance"] > previous_best
	last_result["path"] = session.path
```

## Acceptance criteria
- `set_path` keeps the points and the farthest/highest values; `map_point` maps (0, 0) to (5, 65), the farthest point
  to x 375 and the highest to y 5.
- After a classic shot, `last_result["path"]` is the shot's path and the results screen's `shot_map` shows it; the
  results still fit on screen.
