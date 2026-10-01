---
id: 233-rocket-gauge
status: ready
tests: [tests/acceptance/test_233_rocket_gauge.gd, tests/acceptance/test_031_hud.gd, tests/acceptance/test_063_hints.gd, tests/acceptance/test_200_speed.gd]
files: [scripts/ui/rocket_gauge.gd, scripts/ui/hud.gd, scripts/game/main.gd]
---

# Rocket gauge on the HUD

The HUD's boost line becomes a rocket line: "Rocket: 1.5 s" (seconds of rocket left this flight; "Rocket: none"
before the player has a rocket), with an orange gauge right under it that empties as the rocket burns (hidden without a rocket). The boost hint says to hold
Space. Three older tests are updated for the new texts and layout.

**1. Create the file `scripts/ui/rocket_gauge.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
class_name RocketGauge
extends ProgressBar
## The HUD's rocket gauge: how much of the rocket is left this flight, in orange. Hidden without a rocket.


func _init() -> void:
	custom_minimum_size = Vector2(150, 10)
	max_value = 1.0
	step = 0.0
	show_percentage = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(1.0, 0.55, 0.1)
	fill.set_corner_radius_all(4)
	add_theme_stylebox_override("fill", fill)


## `seconds` of rocket left out of `full` (0 = no rocket: the gauge hides).
func show_fuel(seconds: float, full: float) -> void:
	visible = full > 0.0
	value = clampf(seconds / full, 0.0, 1.0) if full > 0.0 else 0.0
```

**2. `scripts/ui/hud.gd`**: exactly these 5 SEARCH/REPLACE edit(s). Edits 1 and 5 replace one line each, edit 4 replaces the `update_flight` line (new parameters); the others keep the SEARCH lines and add the new ones. Nothing else in hud.gd changes (it must stay under 300 lines).

Edit 1 - SEARCH:
```gdscript
const HINT_BOOST: String = "Press Space in the air to boost!"
```
REPLACE:
```gdscript
const HINT_BOOST: String = "Hold Space in the air to fire the rocket!"
```

Edit 2 - SEARCH:
```gdscript
var goal_bar: ProgressBar
```
REPLACE:
```gdscript
var goal_bar: ProgressBar
var rocket_bar: RocketGauge
```

Edit 3 - SEARCH:
```gdscript
	boosts_label.add_theme_font_size_override("font_size", 22)
```
REPLACE:
```gdscript
	boosts_label.add_theme_font_size_override("font_size", 22)
	rocket_bar = RocketGauge.new()
	left_container.add_child(rocket_bar)
```

Edit 4 - SEARCH:
```gdscript
func update_flight(distance: float, height: float, stars: int, boosts: int) -> void:
```
REPLACE:
```gdscript
## `rocket`: seconds of rocket left; `rocket_max`: a full tank (0 = no rocket).
func update_flight(distance: float, height: float, stars: int, rocket: float, rocket_max: float = 0.0) -> void:
```

Edit 5 - SEARCH:
```gdscript
	boosts_label.text = "Boosts: %d" % boosts
```
REPLACE:
```gdscript
	boosts_label.text = "Rocket: none" if rocket_max <= 0.0 and rocket <= 0.0 else "Rocket: %.1f s" % maxf(rocket, 0.0)
	rocket_bar.show_fuel(rocket, rocket_max)
```

**3. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes the end of that one line in `advance()` (the HUD gets the rocket's fuel and capacity); nothing else in main.gd changes.

Edit 1 - SEARCH:
```gdscript
session.tracker.stars_collected, session.sim.boost_charges)
```
REPLACE:
```gdscript
session.tracker.stars_collected, session.sim.boost_fuel, session.sim.boost_capacity())
```

## Acceptance criteria
- `RocketGauge.show_fuel(seconds, full)` sets the gauge (hidden when `full` is 0).
- The HUD shows "Rocket: %.1f s" and the gauge right under that line; main.gd passes `boost_fuel` and `boost_capacity()`.
- `Hud.HINT_BOOST` is "Hold Space in the air to fire the rocket!".
