---
id: 092-repeat-shot
status: ready
tests: [tests/acceptance/test_092_repeat_shot.gd]
files: [scripts/game/slingshot.gd, scripts/ui/hud.gd, scripts/game/main.gd]
---

# Press R to repeat the last shot

When the last-aim line is unlocked (Aim Guide in classic, Steady Hand in the roguelike), the R key launches again
with exactly the remembered pull.

**1. `scripts/game/slingshot.gd`** (keep everything else):
- In `_unhandled_input()`, add a third branch at the end of the `if ... elif ...` chain:
  ```gdscript
  	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
  		if repeat_last_shot():
  			get_viewport().set_input_as_handled()
  ```
- Add this function right before `cancel_drag()`:
  ```gdscript
  ## Launches again with the remembered pull (the R key), only while the last-aim line is shown.
  func repeat_last_shot() -> bool:
  	if not enabled or dragging or not show_last_aim or last_pull == Vector2.ZERO:
  		return false
  	launched.emit(last_pull)
  	return true
  ```

**2. `scripts/ui/hud.gd`:** add after `const HINT_BOOST ...`:
```gdscript
const HINT_REPEAT: String = "Press R to repeat your last shot"
```

**3. `scripts/game/main.gd`:** in `_begin_aim()`, the hint block becomes (add the `elif` branch):
```gdscript
	if progress.total_runs == 0:
		hud.show_hint(Hud.HINT_AIM)
	elif slingshot.show_last_aim and slingshot.last_pull != Vector2.ZERO:
		hud.show_hint(Hud.HINT_REPEAT)
	else:
		hud.hide_hint()
```

## Acceptance criteria
- `repeat_last_shot()` emits `launched(last_pull)` only when enabled, not dragging, the line is shown and a shot
  was remembered; the R key calls it.
- With Aim Guide, the next shot shows "Press R to repeat your last shot" and R launches with the same pull.
