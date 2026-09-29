---
id: 056-dust-effects
status: ready
tests: [tests/acceptance/test_056_dust_effects.gd]
files: [scripts/game/effects.gd, scripts/game/main.gd]
---

# Particle effects: dust puffs on bounces

**1. Create `scripts/game/effects.gd`:** one-shot CPUParticles2D effects that free themselves when done.
```gdscript
class_name Effects
extends Node2D
## One-shot particle effects (CPUParticles2D) that free themselves when they finish.

const PUFF_TEXTURE: String = "res://assets/sprites/cloud.png"


func spawn_dust(at: Vector2, strength: float) -> CPUParticles2D:
	var p := _make(at, clampi(roundi(strength * 2.0), 6, 24), 0.6)
	p.texture = load(PUFF_TEXTURE)
	p.scale_amount_min = 0.08
	p.scale_amount_max = 0.16
	p.direction = Vector2(0, -1)
	p.spread = 70.0
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 120.0
	p.gravity = Vector2(0, 200)
	p.color = Color(0.55, 0.45, 0.35, 0.8)
	return p


func _make(at: Vector2, amount: int, lifetime: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.position = at
	p.one_shot = true
	p.explosiveness = 0.9
	p.amount = amount
	p.lifetime = lifetime
	p.emitting = true
	p.finished.connect(p.queue_free)
	add_child(p)
	return p
```

**2. `scripts/game/main.gd`** (keep changes small; under 450 lines):
- `var effects: Effects`; in `_ready()` create it and `add_child(effects)` right after `projectile_view` (so
  effects draw over the projectile).
- In `_on_bounced(impact_speed)`, after the sound:
  `effects.spawn_dust(projectile_view.position + Vector2(0, 12), impact_speed)`

## Acceptance criteria
- `spawn_dust` adds a one-shot, emitting CPUParticles2D at the point with 2 particles per m/s of impact
  (6..24), lifetime 0.6, the cloud texture, and frees itself when finished.
- A bounce in main puffs dust at the projectile's feet.
