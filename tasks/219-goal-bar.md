---
id: 219-goal-bar
status: ready
tests: [tests/acceptance/test_219_goal_bar.gd]
files: [scripts/ui/ui_theme.gd, scripts/ui/hud.gd, scripts/game/main.gd]
---

# Progress bar on the HUD

A bar in the HUD's right panel fills toward the next milestone in classic, and toward the goal in the roguelike.

**1. `scripts/ui/ui_theme.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds the bar styles above the `focus` line and keeps it; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
```
REPLACE:
```gdscript
	var bar_back := StyleBoxFlat.new()
	bar_back.bg_color = Color(0, 0, 0, 0.4)
	bar_back.set_corner_radius_all(6)
	theme.set_stylebox("background", "ProgressBar", bar_back)
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = Color(1.0, 0.8, 0.25)
	bar_fill.set_corner_radius_all(6)
	theme.set_stylebox("fill", "ProgressBar", bar_fill)
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
```

**2. `scripts/ui/hud.gd`**: exactly these 6 SEARCH/REPLACE edit(s). Each REPLACE keeps its SEARCH lines (Edit 5 gives `show_goal_progress` a third, optional parameter) and adds new lines; nothing else changes.

Edit 1 - SEARCH:
```gdscript
var speed_label: Label
```
REPLACE:
```gdscript
var speed_label: Label
var goal_bar: ProgressBar
## The next milestone's distance (0 when every milestone is reached).
var next_target: float = 0.0
```

Edit 2 - SEARCH:
```gdscript
	right_container.add_child(goal_progress_label)
```
REPLACE:
```gdscript
	right_container.add_child(goal_progress_label)
	
	goal_bar = ProgressBar.new()
	goal_bar.custom_minimum_size = Vector2(0, 12)
	goal_bar.max_value = 1.0
	goal_bar.step = 0.0
	goal_bar.show_percentage = false
	goal_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_container.add_child(goal_bar)
```

Edit 3 - SEARCH:
```gdscript
	course_bar.set_distance(distance)
```
REPLACE:
```gdscript
	course_bar.set_distance(distance)
	if next_target > 0.0:
		goal_bar.value = clampf(distance / next_target, 0.0, 1.0)
```

Edit 4 - SEARCH:
```gdscript
	if next == {}:
		goal_label.text = "All milestones reached!"
	else:
		goal_label.text = "Next: %s at %d m" % [next["name"], int(next["distance"])]
```
REPLACE:
```gdscript
	if next == {}:
		goal_label.text = "All milestones reached!"
		next_target = 0.0
	else:
		goal_label.text = "Next: %s at %d m" % [next["name"], int(next["distance"])]
		next_target = float(next["distance"])
	goal_bar.value = 1.0 if next_target <= 0.0 else clampf(best / next_target, 0.0, 1.0)
```

Edit 5 - SEARCH:
```gdscript
func show_goal_progress(text: String, met: bool) -> void:
```
REPLACE:
```gdscript
func show_goal_progress(text: String, met: bool, ratio: float = -1.0) -> void:
	if ratio >= 0.0:
		goal_bar.value = ratio
```

Edit 6 - SEARCH:
```gdscript
	goal_label.text = "Goal: %s" % goal_text
```
REPLACE:
```gdscript
	goal_label.text = "Goal: %s" % goal_text
	goal_bar.value = 0.0
```

**3. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE passes the goal's progress ratio as a third argument on that one line; nothing else changes.

Edit 1 - SEARCH:
```gdscript
			hud.show_goal_progress(RogueGoals.progress_text(rogue.goal, so_far), RogueGoals.check(rogue.goal, so_far))
```
REPLACE:
```gdscript
			hud.show_goal_progress(RogueGoals.progress_text(rogue.goal, so_far), RogueGoals.check(rogue.goal, so_far), RogueGoals.progress_ratio(rogue.goal, so_far))
```

## Acceptance criteria
- `hud.goal_bar` sits under the goal lines: best (then this flight's distance) over the next milestone; full when all are reached.
- `show_goal_progress(text, met, ratio)` sets it in the roguelike (main passes `RogueGoals.progress_ratio`); a new round starts empty.
