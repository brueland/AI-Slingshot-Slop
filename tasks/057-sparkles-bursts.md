---
id: 057-sparkles-bursts
status: ready
tests: [tests/acceptance/test_057_sparkles_bursts.gd]
files: [scripts/game/effects.gd, scripts/game/main.gd]
read: [scripts/game/course_view.gd]
---

# Particle effects: star sparkles and spring bursts

**1. `scripts/game/effects.gd`** (keep `spawn_dust` and `_make`): add
`const STAR_TEXTURE: String = "res://assets/sprites/star.png"` and:
```gdscript
func spawn_sparkle(at: Vector2) -> CPUParticles2D:
	var p := _make(at, 12, 0.5)
	p.texture = load(STAR_TEXTURE)
	p.scale_amount_min = 0.1
	p.scale_amount_max = 0.2
	p.spread = 180.0
	p.initial_velocity_min = 80.0
	p.initial_velocity_max = 160.0
	p.gravity = Vector2.ZERO
	p.color = Color(1.0, 0.9, 0.3)
	return p


func spawn_burst(at: Vector2) -> CPUParticles2D:
	var p := _make(at, 16, 0.5)
	p.texture = load(PUFF_TEXTURE)
	p.scale_amount_min = 0.06
	p.scale_amount_max = 0.12
	p.direction = Vector2(0, -1)
	p.spread = 35.0
	p.initial_velocity_min = 150.0
	p.initial_velocity_max = 260.0
	p.gravity = Vector2(0, 300)
	p.color = Color.WHITE
	return p
```

**2. `scripts/game/main.gd`** (keep changes small): the signal handlers get the item index; use it to find the
item's sprite in `course_view.sprites`:
```gdscript
func _on_star_collected(index: int) -> void:
	audio.play_sfx("star")
	if index >= 0 and index < course_view.sprites.size():
		effects.spawn_sparkle(course_view.sprites[index].position)
	# ... keep the existing "+N" popup code
```
and the same in `_on_spring_hit(index: int)` with `effects.spawn_burst(...)` (keep the sound and camera shake).
Rename the parameters from `_index` to `index` since they are used now.

## Acceptance criteria
- Sparkles: 12 gold star particles in every direction; bursts: 16 particles upward (spread under 60); both one-shot
  and self-freeing.
- Collecting a star sparkles at that star's sprite; hitting a spring bursts at that spring's sprite.
