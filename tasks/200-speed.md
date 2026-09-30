---
id: 200-speed
status: ready
tests: [tests/acceptance/test_200_speed.gd]
files: [scripts/ui/hud.gd, scripts/game/main.gd]
---

# Speed on the HUD

The HUD shows the alien's speed during a flight, right under the boosts.

**1. `scripts/ui/hud.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edit 2 adds lines above `altitude_bar = AltitudeBar.new()` and keeps it; Edit 4 adds a function above the `show_goal_progress` comment and keeps it; the other edits keep their SEARCH lines and add new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var course_bar: CourseBar
```
REPLACE:
```gdscript
var course_bar: CourseBar
var speed_label: Label
```

Edit 2 - SEARCH:
```gdscript
	altitude_bar = AltitudeBar.new()
```
REPLACE:
```gdscript
	speed_label = Label.new()
	left_container.add_child(speed_label)
	speed_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	speed_label.add_theme_font_size_override("font_size", 22)
	
	altitude_bar = AltitudeBar.new()
```

Edit 3 - SEARCH:
```gdscript
	update_flight(0.0, 0.0, 0, 0)
```
REPLACE:
```gdscript
	update_flight(0.0, 0.0, 0, 0)
	show_speed(0.0)
```

Edit 4 - SEARCH:
```gdscript
## Roguelike: the live goal readout under the goal ("" hides it); green once the goal is met.
```
REPLACE:
```gdscript
func show_speed(meters_per_second: float) -> void:
	speed_label.text = "Speed: %d m/s" % roundi(meters_per_second)


## Roguelike: the live goal readout under the goal ("" hides it); green once the goal is met.
```

**2. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
		hud.update_flight(session.sim.distance(), session.sim.position.y, session.tracker.stars_collected, session.sim.boost_charges)
```
REPLACE:
```gdscript
		hud.update_flight(session.sim.distance(), session.sim.position.y, session.tracker.stars_collected, session.sim.boost_charges)
		hud.show_speed(session.sim.velocity.length())
```

## Acceptance criteria
- `hud.speed_label` reads `Speed: 23 m/s` (rounded) and shows `Speed: 0 m/s` before a flight.
- main updates it every flight frame.
