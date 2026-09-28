---
id: 026-slingshot-mouse
status: ready
tests: [tests/acceptance/test_026_slingshot_mouse.gd]
files: [scripts/game/slingshot.gd]
---

# Slingshot: mouse input

Add `_unhandled_input` to `scripts/game/slingshot.gd` (keep everything that is there). Mouse positions are in
viewport coordinates; convert them to the slingshot's canvas coordinates before calling the drag functions.

```gdscript
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var point: Vector2 = get_canvas_transform().affine_inverse() * event.position
		if event.pressed:
			if begin_drag(point):
				get_viewport().set_input_as_handled()
		elif dragging:
			release()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and dragging:
		var point: Vector2 = get_canvas_transform().affine_inverse() * event.position
		update_drag(point)
		get_viewport().set_input_as_handled()
```

Declare `point` with an explicit type (`var point: Vector2 = ...`): `event.position` is untyped here, so
`:=` can't infer it and Godot refuses to load the script.

## Acceptance criteria
- Left press on the pouch starts a drag, motion updates the pull, release launches.
- Presses away from the pouch, the right button, and a disabled slingshot are ignored.
