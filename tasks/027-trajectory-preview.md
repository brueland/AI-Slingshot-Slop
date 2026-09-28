---
id: 027-trajectory-preview
status: ready
tests: [tests/acceptance/test_027_trajectory_preview.gd]
files: [scripts/game/trajectory_preview.gd]
read: [scripts/core/flight_sim.gd, scripts/game/world_view.gd]
---

# Trajectory preview dots

Create `scripts/game/trajectory_preview.gd`: dots along the predicted flight while the player aims.

```gdscript
class_name TrajectoryPreview
extends Node2D
## Dots along the predicted flight while aiming. Points are stored in screen pixels.

const STEP_TIME: float = 0.1
const SUBSTEPS: int = 6

var points: PackedVector2Array = PackedVector2Array()


## World-space positions every STEP_TIME seconds, until `count` points or the ground.
static func compute_points(start: Vector2, velocity: Vector2, drag: float, count: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	var sim := FlightSim.new()
	sim.drag = drag
	sim.launch(start, velocity)
	for i in count:
		for s in SUBSTEPS:
			sim.step(STEP_TIME / SUBSTEPS)
		if sim.position.y <= 0.0:
			break
		out.append(sim.position)
	return out
```

Also:
- `func update_preview(start: Vector2, velocity: Vector2, drag: float, count: int) -> void`: clear `points`,
  append `WorldView.world_to_screen(p)` for each world point from `compute_points`, then `queue_redraw()`.
- `func clear() -> void`: clear `points`, `queue_redraw()`.
- `_draw()`: a white semi-transparent `draw_circle` at each point, radius shrinking from 4 to 1.5 along the arc.

## Acceptance criteria
- `compute_points` matches a FlightSim stepped 6 times per 0.1 s, moves forward, and stops at the ground.
- `update_preview` stores the same points converted to screen pixels; `clear()` empties them.
