---
id: 163-victory-confetti
status: ready
tests: [tests/acceptance/test_163_victory_confetti.gd]
files: [scripts/ui/victory_panel.gd]
---

# Victory confetti

The victory screen rains confetti.

**`scripts/ui/victory_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var continue_button: Button
```
REPLACE:
```gdscript
var continue_button: Button
var confetti: CPUParticles2D
```

Edit 2 - SEARCH:
```gdscript
	vbox.add_child(continue_button)
```
REPLACE:
```gdscript
	vbox.add_child(continue_button)
	
	confetti = CPUParticles2D.new()
	confetti.amount = 80
	confetti.lifetime = 2.5
	confetti.emitting = false
	confetti.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	confetti.emission_rect_extents = Vector2(240, 4)
	confetti.position = Vector2(240, -20)
	confetti.direction = Vector2(0, 1)
	confetti.gravity = Vector2(0, 160)
	confetti.initial_velocity_min = 20.0
	confetti.initial_velocity_max = 80.0
	confetti.scale_amount_min = 3.0
	confetti.scale_amount_max = 5.0
	var colors := Gradient.new()
	colors.set_color(0, Color(1.0, 0.3, 0.4))
	colors.set_color(1, Color(0.3, 0.6, 1.0))
	colors.add_point(0.5, Color(1.0, 0.85, 0.2))
	confetti.color_initial_ramp = colors
	add_child(confetti)
```

Edit 3 - SEARCH:
```gdscript
	message_label.text = "You reached %d m in %d runs!" % [int(Balance.GOAL_DISTANCE), runs]
```
REPLACE:
```gdscript
	message_label.text = "You reached %d m in %d runs!" % [int(Balance.GOAL_DISTANCE), runs]
	confetti.emitting = true
```

## Acceptance criteria
- The panel has a `confetti` CPUParticles2D that starts emitting in `show_victory()`.
