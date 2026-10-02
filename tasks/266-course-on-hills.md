---
id: 266-course-on-hills
status: ready
tests: [tests/acceptance/test_266_course_on_hills.gd]
files: [scripts/game/course_view.gd, scripts/game/scenery.gd, scripts/game/cows.gd]
---

# The course stands on the hills

Things standing on the ground were drawn at height 0, so on hills they floated or sank. Now springs, mud, the
milestone flags and the best-distance flag stand on `WorldView.ground_point`, and the rocks, plants and cows move
onto the hills whenever a new shot's terrain arrives (`WorldView.terrain_version` changes).

**1. `scripts/game/course_view.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edits 1, 2 and 4 change where one sprite stands; edit 3 adds a line in `set_best_marker()`'s loop. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
			sprite.position = WorldView.world_to_screen(Vector2(item["x"], 0))
```
REPLACE:
```gdscript
			sprite.position = WorldView.ground_point(item["x"])
```

Edit 2 - SEARCH:
```gdscript
			sprite.position = WorldView.world_to_screen(Vector2(item["x"] + Balance.MUD_WIDTH / 2.0, 0))
```
REPLACE:
```gdscript
			sprite.position = WorldView.ground_point(item["x"] + Balance.MUD_WIDTH / 2.0)
```

Edit 3 - SEARCH:
```gdscript
	for k in flags.size():
		flags[k].modulate = Color(1.0, 0.9, 0.4) if float(Milestones.LIST[k]["distance"]) <= distance else Color.WHITE
```
REPLACE:
```gdscript
	for k in flags.size():
		flags[k].position = WorldView.ground_point(float(Milestones.LIST[k]["distance"]))
		flags[k].modulate = Color(1.0, 0.9, 0.4) if float(Milestones.LIST[k]["distance"]) <= distance else Color.WHITE
```

Edit 4 - SEARCH:
```gdscript
	best_marker.position = WorldView.world_to_screen(Vector2(distance, 0.0))
```
REPLACE:
```gdscript
	best_marker.position = WorldView.ground_point(distance)
```

**2. `scripts/game/scenery.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 2 adds `_process()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var sprites: Array[Sprite2D] = []
```
REPLACE:
```gdscript
var sprites: Array[Sprite2D] = []
## The terrain the sprites stand on (WorldView.terrain_version); they move when it changes.
var seen_terrain: int = -1
```

Edit 2 - SEARCH:
```gdscript
		add_child(sprite)
		sprites.append(sprite)
```
REPLACE:
```gdscript
		add_child(sprite)
		sprites.append(sprite)


## Puts the rocks and plants on the current shot's hills when they change.
func _process(_delta: float) -> void:
	if seen_terrain == WorldView.terrain_version:
		return
	seen_terrain = WorldView.terrain_version
	for sprite in sprites:
		sprite.position.y = WorldView.ground_point(WorldView.screen_to_world(sprite.position).x).y
```

**3. `scripts/game/cows.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 2 changes `cow_position()` and adds `_process()` after it. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var xs: Array[float] = []
```
REPLACE:
```gdscript
var xs: Array[float] = []
## The terrain the cows were drawn on (WorldView.terrain_version).
var seen_terrain: int = -1
```

Edit 2 - SEARCH:
```gdscript
	return WorldView.world_to_screen(Vector2(xs[index], 0.0))
```
REPLACE:
```gdscript
	return WorldView.ground_point(xs[index])


func _process(_delta: float) -> void:
	if seen_terrain != WorldView.terrain_version:
		seen_terrain = WorldView.terrain_version
		queue_redraw()
```

## Acceptance criteria
- Springs, mud and both kinds of flag are placed with `WorldView.ground_point`.
- Scenery sprites and cows follow `WorldView.terrain_version` and sit on the ground.
