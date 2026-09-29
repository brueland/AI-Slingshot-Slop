---
id: 036-boost-pause-input
status: ready
tests: [tests/acceptance/test_036_boost_pause_input.gd]
files: [scripts/game/main.gd]
read: [scripts/game/slingshot.gd]
---

# Main: Space boosts, Esc pauses

Edit `scripts/game/main.gd` (keep everything that works).

1. A `pause_label: Label` on `ui_layer` (create it in `_build_ui()`): text `"Paused - press Esc to resume"`,
   font size 32: `add_theme_font_size_override("font_size", 32)`, centered (`PRESET_CENTER`, grow both ways), hidden at start.
2. Keyboard input. The `boost` action (Space) already exists in project.godot; `ui_cancel` is Godot's built-in
   Esc action:
   ```gdscript
   func _unhandled_input(event: InputEvent) -> void:
   	if event.is_action_pressed("boost"):
   		if request_boost():
   			get_viewport().set_input_as_handled()
   	elif event.is_action_pressed("ui_cancel"):
   		toggle_pause()
   		get_viewport().set_input_as_handled()
   ```
3. Pause:
   ```gdscript
   func toggle_pause() -> void:
   	if state != State.AIM and state != State.FLIGHT:
   		return
   	is_paused = not is_paused
   	pause_label.visible = is_paused
   	slingshot.enabled = state == State.AIM and not is_paused
   	if is_paused:
   		slingshot.cancel_drag()
   ```
   `advance()` and `request_boost()` already do nothing while `is_paused`. Never use `get_tree().paused`
   (it would also freeze the test runner).

## Acceptance criteria
- The boost action spends a boost only during flight.
- Esc pauses and resumes aiming or flight (nothing moves while paused, `pause_label` shows); no pause on the title screen.
