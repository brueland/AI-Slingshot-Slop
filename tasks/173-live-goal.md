---
id: 173-live-goal
status: ready
tests: [tests/acceptance/test_173_live_goal.gd]
files: [scripts/ui/hud.gd, scripts/game/main.gd, scripts/ui/ui_root.gd]
---

# Live goal progress on the HUD

During a roguelike flight the HUD shows the goal's live progress under the goal line, and turns it green once the
goal is met.

**1. `scripts/ui/hud.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var weather_label: Label
```
REPLACE:
```gdscript
var weather_label: Label
var goal_progress_label: Label
```

Edit 2 - SEARCH:
```gdscript
	goal_label.add_theme_font_size_override("font_size", 22)
```
REPLACE:
```gdscript
	goal_label.add_theme_font_size_override("font_size", 22)
	
	goal_progress_label = Label.new()
	goal_progress_label.add_theme_font_size_override("font_size", 20)
	goal_progress_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	goal_progress_label.hide()
	right_container.add_child(goal_progress_label)
```

Edit 3 - SEARCH:
```gdscript
## Roguelike: the right column shows the round, lives and the current goal instead of best/coins/next.
```
REPLACE:
```gdscript
## Roguelike: the live goal readout under the goal ("" hides it); green once the goal is met.
func show_goal_progress(text: String, met: bool) -> void:
	goal_progress_label.text = text
	goal_progress_label.visible = text != ""
	goal_progress_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5) if met else Color.WHITE)


## Roguelike: the right column shows the round, lives and the current goal instead of best/coins/next.
```

**2. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
		hud.update_flight(session.sim.distance(), session.sim.position.y, session.tracker.stars_collected, session.sim.boost_charges)
```
REPLACE:
```gdscript
		hud.update_flight(session.sim.distance(), session.sim.position.y, session.tracker.stars_collected, session.sim.boost_charges)
		if mode == "rogue":
			var so_far: Dictionary = session.result()
			hud.show_goal_progress(RogueGoals.progress_text(rogue.goal, so_far), RogueGoals.check(rogue.goal, so_far))
```

**3. `scripts/ui/ui_root.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	hud.visible = state == "AIM" or state == "FLIGHT"
```
REPLACE:
```gdscript
	hud.visible = state == "AIM" or state == "FLIGHT"
	hud.show_goal_progress("", false)
```

## Acceptance criteria
- `Hud.show_goal_progress(text, met)`; `goal_progress_label` sits right under `goal_label` and is hidden for "".
- main updates it every roguelike flight frame; `UiRoot.refresh` clears it; classic flights never show it.
