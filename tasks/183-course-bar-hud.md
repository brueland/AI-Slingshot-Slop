---
id: 183-course-bar-hud
status: ready
tests: [tests/acceptance/test_183_course_bar_hud.gd]
files: [scripts/ui/hud.gd]
---

# Course bar on the HUD

The HUD shows the course bar at the bottom center; it follows the flight and marks the best distance.

**`scripts/ui/hud.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edit 2 adds lines above the `# Hint label at bottom center` comment and keeps it; the other edits keep their SEARCH lines and add new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var goal_progress_label: Label
```
REPLACE:
```gdscript
var goal_progress_label: Label
var course_bar: CourseBar
```

Edit 2 - SEARCH:
```gdscript
	# Hint label at bottom center
```
REPLACE:
```gdscript
	# Course bar at the very bottom
	course_bar = CourseBar.new()
	course_bar.anchor_left = 0.5
	course_bar.anchor_right = 0.5
	course_bar.anchor_top = 1.0
	course_bar.anchor_bottom = 1.0
	course_bar.offset_left = -200
	course_bar.offset_right = 200
	course_bar.offset_top = -30
	course_bar.offset_bottom = -22
	add_child(course_bar)
	
	# Hint label at bottom center
```

Edit 3 - SEARCH:
```gdscript
	altitude_bar.set_height(height)
```
REPLACE:
```gdscript
	altitude_bar.set_height(height)
	course_bar.set_distance(distance)
```

Edit 4 - SEARCH:
```gdscript
	coins_label.text = "Coins: %d" % coins
```
REPLACE:
```gdscript
	coins_label.text = "Coins: %d" % coins
	course_bar.set_best(best)
```

## Acceptance criteria
- `hud.course_bar` sits at the bottom center, clear of the hint line; `update_flight` moves it and `update_progress` marks the best.
