---
id: 055-ground-shadow
status: ready
tests: [tests/acceptance/test_055_ground_shadow.gd]
files: [scripts/game/ground_shadow.gd, scripts/game/main.gd]
read: [scripts/game/world_view.gd]
---

# A shadow under the projectile

**1. Create `scripts/game/ground_shadow.gd`:** an oval shadow on the ground that shrinks and fades as the
projectile rises (it helps players judge height).
```gdscript
class_name GroundShadow
extends Node2D
## A soft oval shadow on the ground under the projectile; it shrinks and fades as the projectile rises.

const RADIUS_PX: float = 14.0

var shadow_scale: float = 1.0


func update_from(world_pos: Vector2) -> void:
	position = WorldView.world_to_screen(Vector2(world_pos.x, 0.0))
	shadow_scale = clampf(1.0 - world_pos.y / 30.0, 0.3, 1.0)
	queue_redraw()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(shadow_scale, shadow_scale * 0.35))
	draw_circle(Vector2.ZERO, RADIUS_PX, Color(0, 0, 0, 0.35 * shadow_scale))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
```

**2. `scripts/game/main.gd`** (keep changes small):
- `var shadow: GroundShadow`; in `_ready()` create it and `add_child(shadow)` right after the trail (before
  `projectile_view`, so it is drawn behind the projectile).
- `shadow.update_from(session.sim.position)` in `advance()` during FLIGHT (next to the trail update) and at
  the end of `_begin_aim()`.

## Acceptance criteria
- `update_from` keeps the shadow on the ground (screen y = 0) under the projectile's x; scale = 1 - height/30,
  never below 0.3.
- During flight main's shadow follows the projectile.
