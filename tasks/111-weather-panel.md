---
id: 111-weather-panel
status: ready
tests: [tests/acceptance/test_111_weather_panel.gd]
files: [scripts/ui/rogue_panel.gd]
read: [scripts/core/rogue_weather.gd]
---

# Show the weather on the perk panel

The roguelike perk panel shows the weather of the round about to be played, under the next goal, e.g.
"Weather: Tailwind - +8% launch speed".

**`scripts/ui/rogue_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var current_run: RogueRun
```
REPLACE:
```gdscript
var current_run: RogueRun
var weather_label: Label
```

Edit 2 - SEARCH:
```gdscript
	box.add_child(goal_label)
```
REPLACE:
```gdscript
	box.add_child(goal_label)
	weather_label = Label.new()
	weather_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	box.add_child(weather_label)
```

Edit 3 - SEARCH:
```gdscript
	goal_label.text = "Next goal: %s" % run.goal.get("text", "")
```
REPLACE:
```gdscript
	goal_label.text = "Next goal: %s" % run.goal.get("text", "")
	var weather := RogueWeather.get_def(run.weather)
	weather_label.text = "Weather: %s - %s" % [weather["name"], weather["description"]]
```

## Acceptance criteria
- After a shot the panel shows "Weather: <name> - <description>" for `run.weather` (round 2 is "Weather: Calm - no change").
- The panel still fits on screen.
