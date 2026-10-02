---
id: 265-hills-drawn
status: ready
tests: [tests/acceptance/test_265_hills_drawn.gd]
files: [scripts/game/world_view.gd, scripts/game/main.gd]
---

# The hills are drawn

The ground is drawn along the current shot's hills. WorldView keeps the shot's sim as `terrain` (main.gd shows it
for every new shot with `world_view.show_terrain`; the ground is flat again when that WorldView leaves the tree), and `ground_point(x)` is the point on the ground for everything that
stands on it. With hills the dirt and grass are drawn as 2 m textured pieces that follow them; the distance markers
sit on them. Flat ground is drawn as before.

**1. `scripts/game/world_view.gd`**: exactly these 7 SEARCH/REPLACE edit(s). Edit 2 puts the dirt and grass drawing in `_draw()` under an `else` (hills use `_draw_hills`); edits 3-5 put the markers on the ground; edit 6 also redraws when the terrain changes; edit 7 adds `use_terrain()`, `show_terrain()`, `_exit_tree()`, `ground_height_at()`, `ground_point()` and `_draw_hills()` at the end of the file; edit 1 keeps the SEARCH lines and adds the new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var drawn_to_m: float = 730.0
```
REPLACE:
```gdscript
var drawn_to_m: float = 730.0
## The current shot's ground (its hills); null = flat. main.gd sets it for every new shot (use_terrain).
static var terrain: FlightSim = null
## Goes up every time the terrain changes, so the ground and its decorations know to redraw.
static var terrain_version: int = 0
## The WorldView that showed the terrain (instance id); the ground goes back to flat when it leaves the tree.
static var terrain_owner: int = 0
var drawn_version: int = 0
```

Edit 2 - SEARCH:
```gdscript
	var rect := ground_rect(drawn_from_m, drawn_to_m)
	draw_texture_rect(dirt_texture, rect, true, Color(0.85, 0.75, 0.65))
	
	# Draw grass texture tiled along the top
	draw_texture_rect(ground_texture, Rect2(rect.position.x, ground_y - 8, rect.size.x, 32), true)
```
REPLACE:
```gdscript
	if terrain != null and terrain.hills > 0.0:
		_draw_hills(drawn_from_m, drawn_to_m)
	else:
		var rect := ground_rect(drawn_from_m, drawn_to_m)
		draw_texture_rect(dirt_texture, rect, true, Color(0.85, 0.75, 0.65))
		# Draw grass texture tiled along the top
		draw_texture_rect(ground_texture, Rect2(rect.position.x, ground_y - 8, rect.size.x, 32), true)
```

Edit 3 - SEARCH:
```gdscript
		var x: float = d * Balance.PIXELS_PER_METER
```
REPLACE:
```gdscript
		var x: float = d * Balance.PIXELS_PER_METER
		var gy: float = ground_point(float(d)).y
```

Edit 4 - SEARCH:
```gdscript
		draw_line(Vector2(x, ground_y - 8), Vector2(x, ground_y - 20), Color.WHITE, 2)
```
REPLACE:
```gdscript
		draw_line(Vector2(x, gy - 8), Vector2(x, gy - 20), Color.WHITE, 2)
```

Edit 5 - SEARCH:
```gdscript
		var pos: Vector2 = Vector2(x + 4, 56)
```
REPLACE:
```gdscript
		var pos: Vector2 = Vector2(x + 4, gy + 56)
```

Edit 6 - SEARCH:
```gdscript
	if absf(span.x - drawn_from_m) >= DRAW_SPAN_M / 2.0:
		drawn_from_m = span.x
```
REPLACE:
```gdscript
	if absf(span.x - drawn_from_m) >= DRAW_SPAN_M / 2.0 or drawn_version != terrain_version:
		drawn_version = terrain_version
		drawn_from_m = span.x
```

Edit 7 - SEARCH:
```gdscript
		drawn_to_m = span.y
		queue_redraw()
```
REPLACE:
```gdscript
		drawn_to_m = span.y
		queue_redraw()


## Makes `sim` the ground everything is drawn on (its hills; null = flat ground).
static func use_terrain(sim: FlightSim) -> void:
	terrain = sim
	terrain_version += 1


## Shows `sim`'s hills as this world's ground (main.gd calls it for every new shot).
func show_terrain(sim: FlightSim) -> void:
	use_terrain(sim)
	terrain_owner = get_instance_id()


func _exit_tree() -> void:
	if terrain_owner == get_instance_id():
		terrain_owner = 0
		use_terrain(null)


## The ground's height (meters) under x for the current shot: its hills (landing-zone dips are drawn by ZoneMarker).
static func ground_height_at(x_m: float) -> float:
	return terrain.terrain_height(x_m) if terrain != null else 0.0


## The point on the ground under x, in screen pixels.
static func ground_point(x_m: float) -> Vector2:
	return world_to_screen(Vector2(x_m, ground_height_at(x_m)))


## Draws the dirt and the grass following the hills from `from_m` to `to_m`, in 2 m pieces (70 px textures, tiled).
func _draw_hills(from_m: float, to_m: float) -> void:
	var tile := 70.0
	var x := from_m
	while x < to_m:
		var a := ground_point(x)
		var b := ground_point(x + 2.0)
		var deep_a := Vector2(a.x, GROUND_DEPTH_PX)
		var deep_b := Vector2(b.x, GROUND_DEPTH_PX)
		draw_colored_polygon(PackedVector2Array([a, b, deep_b, deep_a]), Color(0.85, 0.75, 0.65),
			PackedVector2Array([a / tile, b / tile, deep_b / tile, deep_a / tile]), dirt_texture)
		draw_colored_polygon(PackedVector2Array([a + Vector2(0, -8), b + Vector2(0, -8), b + Vector2(0, 24), a + Vector2(0, 24)]),
			Color.WHITE, PackedVector2Array([Vector2(a.x / tile, 0.0), Vector2(b.x / tile, 0.0), Vector2(b.x / tile, 32.0 / tile),
			Vector2(a.x / tile, 32.0 / tile)]), ground_texture)
		x += 2.0
```

**2. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds one line in `_begin_aim()` after the session is made; nothing else in main.gd changes (it must stay under 450 lines).

Edit 1 - SEARCH:
```gdscript
		session = RunSession.new(progress.stats(), progress.total_runs + 1)
```
REPLACE:
```gdscript
		session = RunSession.new(progress.stats(), progress.total_runs + 1)
	world_view.show_terrain(session.sim)
```

## Acceptance criteria
- `WorldView.use_terrain(sim)` sets `terrain` and raises `terrain_version`; `ground_height_at(x)` and `ground_point(x)` follow it.
- `show_terrain(sim)` also makes this WorldView the terrain's owner; when it leaves the tree the terrain goes back to null.
- With hills, `_draw` draws `_draw_hills`; markers sit on the ground; main.gd calls `world_view.show_terrain(session.sim)` for every shot.
