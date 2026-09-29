---
id: 065-boost-flame
status: ready
tests: [tests/acceptance/test_065_boost_flame.gd]
files: [scripts/game/effects.gd, scripts/game/main.gd]
---

# A flame when boosting

**1. `scripts/game/effects.gd`** (keep everything): add, before `_make`:
```gdscript
func spawn_flame(at: Vector2) -> CPUParticles2D:
	var p := _make(at, 20, 0.4)
	p.texture = load(PUFF_TEXTURE)
	p.scale_amount_min = 0.05
	p.scale_amount_max = 0.1
	p.direction = Vector2(-1, 1).normalized()
	p.spread = 25.0
	p.initial_velocity_min = 120.0
	p.initial_velocity_max = 220.0
	p.gravity = Vector2.ZERO
	p.color = Color(1.0, 0.55, 0.1)
	return p
```
(`direction` (-1, 1) is down-left on screen: out of the back of a projectile flying up-right.)

**2. `scripts/game/main.gd`:** in `_on_boosted()`, after the sound:
```gdscript
	effects.spawn_flame(projectile_view.position)
	camera.shake(3.0, 0.15)
```

## Acceptance criteria
- `spawn_flame` makes a one-shot orange flame of 20 particles for 0.4 s pointing down-left, freeing itself.
- Boosting in main spawns the flame at the projectile and shakes the camera a little.
