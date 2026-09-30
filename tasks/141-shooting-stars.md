---
id: 141-shooting-stars
status: ready
tests: [tests/acceptance/test_141_shooting_stars.gd]
files: [scripts/game/star_field.gd]
---

# Shooting stars

While the night stars are out (high up), a shooting star crosses the sky every 3 seconds.

**`scripts/game/star_field.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var time: float = 0.0
```
REPLACE:
```gdscript
var time: float = 0.0
var shooting: Array[Vector3] = []
```

Edit 2 - SEARCH:
```gdscript
		time += delta
		queue_redraw()
```
REPLACE:
```gdscript
		time += delta
		advance_shooting(delta)
		queue_redraw()
```

Edit 3 - SEARCH:
```gdscript
func _draw() -> void:
```
REPLACE:
```gdscript
## A shooting star every 3 seconds while the stars are out; each one crosses the sky in 1 second.
func advance_shooting(delta: float) -> void:
	if fmod(time, 3.0) < delta:
		shooting.append(Vector3(fposmod(time * 211.0, 1400.0) - 700.0, -650.0, 0.0))
	for i in range(shooting.size() - 1, -1, -1):
		var s := shooting[i]
		s.z += delta
		if s.z >= 1.0:
			shooting.remove_at(i)
		else:
			shooting[i] = s


## Where a shooting star's head is: it starts at (x, y) and flies down and to the right.
static func shooting_position(s: Vector3) -> Vector2:
	return Vector2(s.x, s.y) + Vector2(420.0, 180.0) * s.z


func _draw() -> void:
```

Edit 4 - SEARCH:
```gdscript
		draw_circle(Vector2(s.x, s.y), 1.5 + 0.8 * twinkle, Color(1.0, 1.0, 0.9, twinkle))
```
REPLACE:
```gdscript
		draw_circle(Vector2(s.x, s.y), 1.5 + 0.8 * twinkle, Color(1.0, 1.0, 0.9, twinkle))
	for streak in shooting:
		var head := shooting_position(streak)
		draw_line(head, head - Vector2(60.0, 26.0), Color(1.0, 1.0, 0.9, 1.0 - streak.z), 2.0)
```

## Acceptance criteria
- A shooting star appears every 3 s while the stars are visible, flies down and right, and is gone after 1 s.
