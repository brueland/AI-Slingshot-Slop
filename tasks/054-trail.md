---
id: 054-trail
status: ready
tests: [tests/acceptance/test_054_trail.gd]
files: [scripts/game/trail.gd, scripts/game/main.gd]
---

# A fading trail behind the projectile

**1. Create `scripts/game/trail.gd`:**
```gdscript
class_name Trail
extends Line2D
## A fading line behind the flying projectile (the newest point is the brightest).

const MAX_POINTS: int = 30


func _ready() -> void:
	width = 8.0
	joint_mode = Line2D.LINE_JOINT_ROUND
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0.0))
	fade.set_color(1, Color(1, 1, 1, 0.7))
	gradient = fade


func add_trail_point(point: Vector2) -> void:
	add_point(point)
	while get_point_count() > MAX_POINTS:
		remove_point(0)


func clear_trail() -> void:
	clear_points()
```

**2. `scripts/game/main.gd`** (keep changes small; under 450 lines):
- `var trail: Trail`; in `_ready()` create it and `add_child(trail)` right after the trajectory preview (so it
  is drawn **before**, i.e. behind, `projectile_view`).
- In `advance()` during FLIGHT, right after `projectile_view.sync_from(session.sim)`:
  `trail.add_trail_point(projectile_view.position)`.
- In `_begin_aim()`: `trail.clear_trail()`.

## Acceptance criteria
- The trail keeps only the newest 30 points, fades out toward its oldest end, and `clear_trail()` empties it.
- During flight main's trail ends at the projectile; the next shot starts with no trail.
