---
id: 236-zone-dip-world
status: ready
tests: [tests/acceptance/test_236_zone_dip_world.gd]
files: [scripts/game/main.gd, scripts/game/ground_shadow.gd, scripts/game/zone_marker.gd]
---

# The dip on the field

Task 235 added dips to the flight. Now every roguelike shot with a landing zone has the zone's dip in its physics
(main.gd sets `session.sim.dips` to the zones of the goal, so a boss goal with a zone part gets one too), the zone
marker draws the dip (a shaded hollow where the flat grass was, with grass along its slopes and floor), and the
alien's shadow sits on the
ground's height under it.

**1. `scripts/game/main.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds one line in `_begin_aim()`; edit 2 changes the shadow line in `advance()`. Nothing else in main.gd changes (it must stay under 450 lines).

Edit 1 - SEARCH:
```gdscript
		session = RunSession.new(rogue.stats(), rogue.shot_seed())
```
REPLACE:
```gdscript
		session = RunSession.new(rogue.stats(), rogue.shot_seed())
		session.sim.dips = ZoneMarker.zones_for(rogue.goal)
```

Edit 2 - SEARCH:
```gdscript
		shadow.update_from(session.sim.position)
		camera.follow```
REPLACE:
```gdscript
		shadow.update_from(session.sim.position, session.sim.ground_height(session.sim.position.x))
		camera.follow```

**2. `scripts/game/ground_shadow.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE gives `update_from()` an optional `ground` height; nothing else changes.

Edit 1 - SEARCH:
```gdscript
func update_from(world_pos: Vector2) -> void:
	position = WorldView.world_to_screen(Vector2(world_pos.x, 0.0))
	shadow_scale = clampf(1.0 - world_pos.y / 30.0, 0.3, 1.0)
```
REPLACE:
```gdscript
## `ground`: the ground's height under the alien (lower in a landing zone's dip).
func update_from(world_pos: Vector2, ground: float = 0.0) -> void:
	position = WorldView.world_to_screen(Vector2(world_pos.x, ground))
	shadow_scale = clampf(1.0 - (world_pos.y - ground) / 30.0, 0.3, 1.0)
```

**3. `scripts/game/zone_marker.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 2 draws the dip right after the band in the loop of `_draw()`; edit 3 adds `dip_outline()` and `_draw_dip()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
const FLAG_COLOR := Color(0.2, 0.75, 0.3)
```
REPLACE:
```gdscript
const FLAG_COLOR := Color(0.2, 0.75, 0.3)
## The dip under the zone: a shaded hollow where the flat grass was, and grass along its slopes and floor.
const DIP_COLOR := Color(0.15, 0.32, 0.12)
const DIP_GRASS := Color(0.49, 0.77, 0.16)
## The ground's grass is drawn this many pixels above the ground line.
const GRASS_TOP: float = 8.0
```

Edit 2 - SEARCH:
```gdscript
		draw_rect(Rect2(a + Vector2(0, -48), Vector2(b.x - a.x, 56)), BAND_COLOR)
```
REPLACE:
```gdscript
		draw_rect(Rect2(a + Vector2(0, -48), Vector2(b.x - a.x, 56)), BAND_COLOR)
		_draw_dip(dip_outline(zone))
```

Edit 3 - SEARCH:
```gdscript
		draw_string(font, at, "STOP HERE", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
```
REPLACE:
```gdscript
		draw_string(font, at, "STOP HERE", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)


## The ground's outline through the dip under `zone`, in screen pixels: the top of the near slope, the floor's two
## ends, and the top of the far slope (Balance.DIP_SLOPE meters outside the zone, Balance.DIP_DEPTH down).
static func dip_outline(zone: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.append(WorldView.world_to_screen(Vector2(zone.x - Balance.DIP_SLOPE, 0.0)))
	out.append(WorldView.world_to_screen(Vector2(zone.x, -Balance.DIP_DEPTH)))
	out.append(WorldView.world_to_screen(Vector2(zone.y, -Balance.DIP_DEPTH)))
	out.append(WorldView.world_to_screen(Vector2(zone.y + Balance.DIP_SLOPE, 0.0)))
	return out


## Draws a dip from its outline: the shaded hollow covers the flat grass across it, and grass follows its slopes
## and floor.
func _draw_dip(outline: PackedVector2Array) -> void:
	var surface := PackedVector2Array()
	for p in outline:
		surface.append(p + Vector2(0.0, -GRASS_TOP))
	var hollow := surface.duplicate()
	hollow.append(Vector2(outline[3].x, -GRASS_TOP - 2.0))
	hollow.append(Vector2(outline[0].x, -GRASS_TOP - 2.0))
	draw_colored_polygon(hollow, DIP_COLOR)
	draw_polyline(surface, DIP_GRASS, 6.0)
```

## Acceptance criteria
- A roguelike zone round's `session.sim.dips` is `ZoneMarker.zones_for(goal)`; classic and other goals have none.
- `ZoneMarker.dip_outline(zone)` returns the 4 screen points of the dip, and `_draw()` draws it.
- `GroundShadow.update_from(pos, ground)` puts the shadow on the ground's height.
