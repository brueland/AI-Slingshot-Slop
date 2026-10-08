---
id: 294-scenery-goes-on
status: ready
tests: [tests/acceptance/test_294_scenery_goes_on.gd]
files: [scripts/game/scenery.gd]
---

# Rocks and plants go on

The rocks, bushes and cacti stopped at 8000 m. Now their layout repeats every LENGTH (8000) meters: Scenery keeps
each sprite's layout x (`base_xs`) and, whenever the view has moved 100 m (or the hills changed), moves each sprite
to its copy nearest the view, on the ground.

**1. `scripts/game/scenery.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edit 1 adds two variables; edits 2 and 3 add one line each in `build()`; edit 4 replaces `_process()` (the last function in the file). Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var seen_terrain: int = -1
```
REPLACE:
```gdscript
var seen_terrain: int = -1
## Each sprite's x in the layout (meters); the layout repeats every LENGTH meters (see _process).
var base_xs: Array[float] = []
## The middle of the view (meters) when the sprites were last placed.
var placed_near: float = 0.0
```

Edit 2 - SEARCH:
```gdscript
	sprites.clear()
```
REPLACE:
```gdscript
	sprites.clear()
	base_xs.clear()
```

Edit 3 - SEARCH:
```gdscript
		add_child(sprite)
		sprites.append(sprite)
```
REPLACE:
```gdscript
		add_child(sprite)
		sprites.append(sprite)
		base_xs.append(item_x)
```

Edit 4 - SEARCH:
```gdscript
## Puts the rocks and plants on the current shot's hills when they change.
func _process(_delta: float) -> void:
	if seen_terrain == WorldView.terrain_version:
		return
	seen_terrain = WorldView.terrain_version
	for sprite in sprites:
		sprite.position.y = WorldView.ground_point(WorldView.screen_to_world(sprite.position).x).y
```
REPLACE:
```gdscript
## Puts the rocks and plants on the current shot's hills when they change, and moves each one to its copy nearest
## the view (the layout repeats every LENGTH meters) whenever the view has moved 100 m.
func _process(_delta: float) -> void:
	var span := WorldView.visible_span(self, 0.0)
	var middle := (span.x + span.y) / 2.0
	var terrain_changed := seen_terrain != WorldView.terrain_version
	if not terrain_changed and absf(middle - placed_near) < 100.0:
		return
	seen_terrain = WorldView.terrain_version
	placed_near = middle
	for i in sprites.size():
		var x := WorldView.repeat_x(base_xs[i], LENGTH, middle)
		if terrain_changed or not is_equal_approx(sprites[i].position.x, x * Balance.PIXELS_PER_METER):
			sprites[i].position = WorldView.ground_point(x)
```

## Acceptance criteria
- `Scenery.base_xs` holds each sprite's layout x; sprites follow the view to their nearest copy, on the ground.
