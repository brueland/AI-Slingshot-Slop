---
id: 095-ghost-path
status: ready
tests: [tests/acceptance/test_095_ghost_path.gd]
files: [scripts/game/ghost_path.gd, scripts/core/run_session.gd, scripts/core/progress.gd, scripts/game/main.gd]
---

# Ghost of the best run

RunSession records the flight path. When a classic run sets a new best, its path is saved, and later classic shots
show it as a faint dotted "ghost" line to beat.

**1. Create the file `scripts/game/ghost_path.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
class_name GhostPath
extends Node2D
## A faint dotted line along the best run so far (classic mode), so the player can see the path to beat.

const MAX_POINTS: int = 200
const DOT_COLOR := Color(1, 1, 1, 0.35)

var points: PackedVector2Array = PackedVector2Array()


## A saveable copy of a flight path: about MAX_POINTS [x, y] pairs (plus the last point), rounded to centimeters.
static func pack(path: PackedVector2Array) -> Array:
	var out: Array = []
	if path.is_empty():
		return out
	var every := maxi(1, ceili(path.size() / float(MAX_POINTS)))
	for i in range(0, path.size(), every):
		out.append([snappedf(path[i].x, 0.01), snappedf(path[i].y, 0.01)])
	if (path.size() - 1) % every != 0:
		var last := path[path.size() - 1]
		out.append([snappedf(last.x, 0.01), snappedf(last.y, 0.01)])
	return out


static func unpack(data: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for item in data:
		if item is Array and item.size() == 2:
			out.append(Vector2(float(item[0]), float(item[1])))
	return out


func set_points(world_points: PackedVector2Array) -> void:
	points = world_points
	queue_redraw()


func _draw() -> void:
	for p in points:
		draw_circle(WorldView.world_to_screen(p + Vector2(0.0, Balance.PROJECTILE_RADIUS)), 2.5, DOT_COLOR)
```

**2. `scripts/core/run_session.gd`** (keep everything else):
- **Declare the variables** after `var elapsed: float = 0.0`:
  ```gdscript
  var path: PackedVector2Array = PackedVector2Array()
  var _steps: int = 0
  ```
- In `launch_from_pull()`, right after `elapsed = 0.0`:
  ```gdscript
  	path = PackedVector2Array([sim.position])
  	_steps = 0
  ```
- At the very end of `step()` (after the `MAX_RUN_SECONDS` check):
  ```gdscript
  	_steps += 1
  	if _steps % 6 == 0 or sim.stopped:
  		path.append(sim.position)
  ```

**3. `scripts/core/progress.gd`** (keep everything else):
- **Declare** `var best_path: Array = []` after `var hat: String = "none"`.
- `to_dict()`: add `"best_path": best_path.duplicate(true),`.
- `from_dict()`: right before the line `var hat_id := str(data.get("hat", "none"))`, add:
  ```gdscript
  	var path_data = data.get("best_path")
  	if typeof(path_data) == TYPE_ARRAY:
  		for item in path_data:
  			if typeof(item) == TYPE_ARRAY and item.size() == 2:
  				p.best_path.append([float(item[0]), float(item[1])])
  ```

**4. `scripts/game/main.gd`** (only these edits):
- **Declare** `var ghost: GhostPath` after `var trajectory: TrajectoryPreview`.
- In `_ready()`, right after `add_child(trajectory)`:
  ```gdscript
  	ghost = GhostPath.new()
  	add_child(ghost)
  ```
- In `_begin_aim()`, right after `balloon_view.build(session.balloons)`:
  ```gdscript
  	ghost.set_points(GhostPath.unpack(progress.best_path) if mode == "classic" else PackedVector2Array())
  ```
- In `_finish_run()`, right after `progress.record_lifetime(last_result)`:
  ```gdscript
  	if last_result["distance"] > previous_best:
  		progress.best_path = GhostPath.pack(session.path)
  ```

## Acceptance criteria
- A shot's `path` starts at the slingshot, gets a point every 6 steps and ends where the alien stopped.
- `pack` keeps about 200 rounded points plus the last one; `unpack` skips bad entries.
- A new classic best saves its path; later classic shots show it; shorter runs keep the old ghost; no ghost in
  the roguelike.
