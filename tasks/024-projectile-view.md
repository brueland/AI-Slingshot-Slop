---
id: 024-projectile-view
status: ready
tests: [tests/acceptance/test_024_projectile_view.gd]
files: [scripts/game/projectile_view.gd]
read: [scripts/game/world_view.gd, scripts/core/flight_sim.gd, scripts/core/balance.gd]
---

# ProjectileView: the alien on screen

Create `scripts/game/projectile_view.gd`, a Sprite2D that shows the projectile where the FlightSim says it is.

```gdscript
class_name ProjectileView
extends Sprite2D
## The alien projectile, drawn where the FlightSim says it is.

const TEXTURES: Array[String] = [
	"res://assets/sprites/projectile_1.png",
	"res://assets/sprites/projectile_2.png",
	"res://assets/sprites/projectile_3.png",
]

var tier: int = 0
```

- `_ready()`: `set_tier(tier)`
- `func set_tier(new_tier: int) -> void`: `tier = clampi(new_tier, 0, 2)`; `texture = load(TEXTURES[tier])`;
  scale the sprite so it is `2 * Balance.PROJECTILE_RADIUS` meters wide on screen:
  `scale = Vector2.ONE * (Balance.PROJECTILE_RADIUS * 2.0 * Balance.PIXELS_PER_METER) / texture.get_width()`
  (the textures are 70 px wide, so the scale is 24/70).
- `func show_at(world_pos: Vector2) -> void`: the sprite's center is one radius above the given point:
  `position = WorldView.world_to_screen(world_pos + Vector2(0.0, Balance.PROJECTILE_RADIUS))`
- `func sync_from(sim: FlightSim) -> void`: `show_at(sim.position)` and roll it:
  `rotation = sim.position.x / Balance.PROJECTILE_RADIUS`

## Acceptance criteria
- Starts with projectile_1.png at scale 24/70; `show_at(Vector2(10, 0))` puts it at (160, -12).
- `sync_from` a sim at (3, 5) puts it at (48, -92) with rotation 4.0; `set_tier` switches textures and clamps to 0..2.
