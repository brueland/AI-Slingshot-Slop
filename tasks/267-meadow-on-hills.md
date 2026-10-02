---
id: 267-meadow-on-hills
status: ready
tests: [tests/acceptance/test_267_meadow_on_hills.gd]
files: [scripts/game/critters.gd, scripts/game/flowers.gd, scripts/game/kites.gd]
---

# The meadow on the hills

The last things standing at height 0 move onto the hills: the sheep, the flowers (they redraw when the terrain
changes) and the kites, whose strings start on the ground at their anchors.

**1. `scripts/game/critters.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes that line in `sheep_position()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	return WorldView.world_to_screen(Vector2(xs[index], 0.0)) - Vector2(0.0, hop_offset(index))
```
REPLACE:
```gdscript
	return WorldView.ground_point(xs[index]) - Vector2(0.0, hop_offset(index))
```

**2. `scripts/game/flowers.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var ages: Array[float] = []
```
REPLACE:
```gdscript
var ages: Array[float] = []
## The terrain the flowers were drawn on (WorldView.terrain_version).
var seen_terrain: int = -1
```

Edit 2 - SEARCH:
```gdscript
	if growing:
		queue_redraw()
```
REPLACE:
```gdscript
	if growing or seen_terrain != WorldView.terrain_version:
		seen_terrain = WorldView.terrain_version
		queue_redraw()
```

Edit 3 - SEARCH:
```gdscript
		var base := WorldView.world_to_screen(Vector2(xs[i], 0.0))
```
REPLACE:
```gdscript
		var base := WorldView.ground_point(xs[i])
```

**3. `scripts/game/kites.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE changes one line; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	return WorldView.world_to_screen(Vector2(ANCHORS_M[index], 0.0) + sway)
```
REPLACE:
```gdscript
	return WorldView.ground_point(ANCHORS_M[index]) + WorldView.world_to_screen(sway)
```

Edit 2 - SEARCH:
```gdscript
		var base := WorldView.world_to_screen(Vector2(ANCHORS_M[i], 0.0))
```
REPLACE:
```gdscript
		var base := WorldView.ground_point(ANCHORS_M[i])
```

## Acceptance criteria
- `sheep_position`, the flowers' base and the kites' anchors use `WorldView.ground_point`.
