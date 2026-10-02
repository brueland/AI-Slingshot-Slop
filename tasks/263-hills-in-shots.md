---
id: 263-hills-in-shots
status: ready
tests: [tests/acceptance/test_263_hills_in_shots.gd]
files: [scripts/core/run_session.gd, scripts/core/run_tracker.gd]
---

# Hills in every shot

The hills (task 262) now take part in shots. RunSession gives the sim its stats' `hills` and `flat_spans`, shifts
the waves per course (`hill_phase` from the course seed), keeps the boss's ground flat, and moves every course
item up or down by the hills under it: springs and mud sit on them, stars float the same height over them. Mud now
checks the ground's height instead of 0.

**1. `scripts/core/run_session.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	if stats.boss != null:
		boss = stats.boss.copy()
```
REPLACE:
```gdscript
	if stats.boss != null:
		boss = stats.boss.copy()
	sim.hills = stats.hills
	sim.hill_phase = float(course_seed % 997) * 0.731
	sim.flat_spans = stats.flat_spans.duplicate()
	if boss != null:
		sim.flat_spans.append(Vector2(boss.x - 10.0, boss.x + 10.0))
	# course items sit on the hills (springs, mud) or float over them (stars)
	for item in course:
		item["y"] = float(item["y"]) + sim.terrain_height(float(item["x"]))
```

**2. `scripts/core/run_tracker.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes the mud's `if` line in `after_step()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
				if sim.position.y <= 0.0 and sim.position.x >= x and sim.position.x <= x + Balance.MUD_WIDTH:
```
REPLACE:
```gdscript
				if sim.position.y <= sim.ground_height(sim.position.x) + 0.01 and sim.position.x >= x and sim.position.x <= x + Balance.MUD_WIDTH:
```

## Acceptance criteria
- `RunSession` sets `sim.hills`, `sim.hill_phase` (course seed % 997 * 0.731) and `sim.flat_spans` (plus boss.x +/- 10 m), and adds `sim.terrain_height(x)` to every item's y.
- Mud works wherever the alien is on the ground.
