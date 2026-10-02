---
id: 247-grab-the-alien
status: ready
tests: [tests/acceptance/test_247_grab_the_alien.gd]
files: [scripts/game/slingshot.gd, scripts/game/main.gd]
---

# Grab the alien anywhere

The slingshot could only be grabbed within 48 px of the pouch, at the alien's feet. The roguelike's big alien is
90 px tall, so clicking on it mostly missed. Now a drag can also start anywhere on the alien resting on the pouch
(`on_ball`), using its drawn radius from the stats. The pull follows the hand from where it grabbed
(`grab_offset`), so nothing jumps, and while dragging the alien sits in the pouch at its size.

**1. `scripts/game/slingshot.gd`**: exactly these 5 SEARCH/REPLACE edit(s). Edit 3 changes the condition in `begin_drag()` and adds one line; edit 4 changes one line in `update_drag()`; edit 5 adds `on_ball()` at the end of the file; the others keep the SEARCH lines and add the new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var key_aiming: bool = false
```
REPLACE:
```gdscript
var key_aiming: bool = false
## The alien's drawn radius in pixels as it rests on the pouch (bigger for the roguelike's big size).
var ball_radius_px: float = Balance.PROJECTILE_RADIUS * Balance.LOOK_SCALE * Balance.PIXELS_PER_METER
## Where the drag started, from the anchor: the pull follows the hand from there.
var grab_offset: Vector2 = Vector2.ZERO
```

Edit 2 - SEARCH:
```gdscript
	frame_height_px = stats.launch_height * Balance.PIXELS_PER_METER
```
REPLACE:
```gdscript
	frame_height_px = stats.launch_height * Balance.PIXELS_PER_METER
	ball_radius_px = stats.pickup_offset * Balance.PIXELS_PER_METER
```

Edit 3 - SEARCH:
```gdscript
	if not enabled or point.distance_to(global_position) > GRAB_RADIUS:
		return false
	dragging = true
```
REPLACE:
```gdscript
	if not enabled or (point.distance_to(global_position) > GRAB_RADIUS and not on_ball(point)):
		return false
	grab_offset = point - global_position
	dragging = true
```

Edit 4 - SEARCH:
```gdscript
		pull = LaunchMath.clamp_pull(point - global_position, max_pull)
```
REPLACE:
```gdscript
		pull = LaunchMath.clamp_pull(point - grab_offset - global_position, max_pull)
```

Edit 5 - SEARCH:
```gdscript
		draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), power_color(ratio))
```
REPLACE:
```gdscript
		draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), power_color(ratio))


## Is `point` on the alien resting on the pouch (its circle sits right above the anchor)?
func on_ball(point: Vector2) -> bool:
	return point.distance_to(global_position + Vector2(0.0, -ball_radius_px)) <= ball_radius_px + 6.0
```

**2. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes that one line in `_update_aim()`; nothing else in main.gd changes.

Edit 1 - SEARCH:
```gdscript
	projectile_view.position = slingshot.pouch_position() + Vector2(0, -12)
```
REPLACE:
```gdscript
	projectile_view.position = slingshot.pouch_position() + Vector2(0.0, -slingshot.ball_radius_px * 2.0 / 3.0)
```

## Acceptance criteria
- `Slingshot.ball_radius_px` comes from `stats.pickup_offset` (18 px normal, 45 px big); `on_ball(point)` is true on the resting alien.
- `begin_drag` works at the pouch or on the alien and remembers `grab_offset`; `update_drag` uses it.
- While dragging, the alien is drawn `ball_radius_px * 2 / 3` above the pouch.
