---
id: 162-reached-flags
status: ready
tests: [tests/acceptance/test_162_reached_flags.gd]
files: [scripts/game/course_view.gd]
---

# Reached flags glow

Milestone flags glow gold once their distance has been reached.

**`scripts/game/course_view.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. (The two new lines are the first lines of `set_best_marker()`.)

Edit 1 - SEARCH:
```gdscript
func set_best_marker(distance: float) -> void:
```
REPLACE:
```gdscript
func set_best_marker(distance: float) -> void:
	for k in flags.size():
		flags[k].modulate = Color(1.0, 0.9, 0.4) if float(Milestones.LIST[k]["distance"]) <= distance else Color.WHITE
```

## Acceptance criteria
- `set_best_marker(d)` colors the flags of milestones at or below `d` gold, the others white.
