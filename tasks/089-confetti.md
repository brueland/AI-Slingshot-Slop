---
id: 089-confetti
status: ready
tests: [tests/acceptance/test_089_confetti.gd]
files: [scripts/game/effects.gd, scripts/game/feedback.gd, scripts/game/main.gd]
read: [scripts/game/floating_text.gd]
---

# Confetti for great moments

**1. `scripts/game/effects.gd`:** add this function right before `_make()` (keep everything else):
```gdscript
## Party confetti: many small squares in bright colors that burst up and flutter down.
func spawn_confetti(at: Vector2) -> CPUParticles2D:
	var p := _make(at, 60, 1.1)
	p.direction = Vector2(0, -1)
	p.spread = 70.0
	p.initial_velocity_min = 180.0
	p.initial_velocity_max = 340.0
	p.gravity = Vector2(0, 420)
	p.angular_velocity_min = -360.0
	p.angular_velocity_max = 360.0
	p.scale_amount_min = 3.0
	p.scale_amount_max = 5.0
	var colors := Gradient.new()
	colors.set_color(0, Color(1.0, 0.3, 0.4))
	colors.set_color(1, Color(0.3, 0.6, 1.0))
	colors.add_point(0.33, Color(1.0, 0.85, 0.2))
	colors.add_point(0.66, Color(0.4, 0.9, 0.4))
	p.color_initial_ramp = colors
	return p
```

**2. `scripts/game/feedback.gd`:** add this function right before `_on_star_collected()`:
```gdscript
## Confetti and a big popup for great moments: a new best, a milestone, or a roguelike goal met.
## Returns the popup text ("" when there is nothing to celebrate).
func celebrate(result: Dictionary) -> String:
	var milestones: Array = result.get("milestones", [])
	var text := ""
	if bool(result.get("new_best", false)):
		text = "NEW BEST!"
	elif not milestones.is_empty():
		text = "Milestone!"
	elif bool(result.get("goal_met", false)):
		text = "Goal!"
	if text == "":
		return ""
	effects.spawn_confetti(projectile_view.position + Vector2(0, -20))
	var popup := FloatingText.new()
	popup.setup(text, Color(1.0, 0.55, 0.9))
	popup.position = projectile_view.position + Vector2(-50.0, -80.0)
	popups.add_child(popup)
	return text
```

**3. `scripts/game/main.gd`** (two lines in `_finish_run()`):
- In the roguelike branch, right after `rogue_outcome = rogue.finish_shot(last_result)`:
  ```gdscript
  		feedback.celebrate({"goal_met": rogue_outcome["met"]})
  ```
- In the classic part, right after `last_result["new_best"] = last_result["distance"] > previous_best`:
  ```gdscript
  	feedback.celebrate(last_result)
  ```

## Acceptance criteria
- `spawn_confetti` makes a one-shot, many-colored burst of 60 particles that frees itself.
- `celebrate` shows confetti and "NEW BEST!" (new best), else "Milestone!" (a milestone), else "Goal!" (roguelike
  goal met); otherwise nothing, returning "".
- A classic new best and a met roguelike goal each throw confetti once.
