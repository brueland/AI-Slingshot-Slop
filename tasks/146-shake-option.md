---
id: 146-shake-option
status: ready
tests: [tests/acceptance/test_146_shake_option.gd]
files: [scripts/ui/options_panel.gd, scripts/game/main.gd, scripts/game/world_builder.gd, scripts/ui/ui_root.gd]
---

# Screen shake option

The Options screen gets a "Screen shake" switch. It is saved and applied to the camera right away and on start.

**1. `scripts/ui/options_panel.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
signal closed
```
REPLACE:
```gdscript
signal closed
signal shake_toggled(on: bool)
```

Edit 2 - SEARCH:
```gdscript
var close_button: Button
```
REPLACE:
```gdscript
var close_button: Button
var shake_check: CheckButton
```

Edit 3 - SEARCH:
```gdscript
	close_button = Button.new()
```
REPLACE:
```gdscript
	shake_check = CheckButton.new()
	shake_check.text = "Screen shake"
	shake_check.button_pressed = true
	shake_check.toggled.connect(func(on: bool): shake_toggled.emit(on))
	box.add_child(shake_check)
	
	close_button = Button.new()
```

Edit 4 - SEARCH:
```gdscript
func set_values(music: float, sfx: float) -> void:
```
REPLACE:
```gdscript
func set_shake(on: bool) -> void:
	shake_check.set_pressed_no_signal(on)


func set_values(music: float, sfx: float) -> void:
```

**2. `scripts/game/main.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. (Edit 1 adds a line right before `options_panel.show()` in `open_options()`.)

Edit 1 - SEARCH:
```gdscript
	options_panel.show()
```
REPLACE:
```gdscript
	options_panel.set_shake(progress.shake_on)
	options_panel.show()
```

Edit 2 - SEARCH:
```gdscript
func choose_hat(id: String) -> bool:
```
REPLACE:
```gdscript
## The Screen shake option: saved, and applied to the camera right away.
func set_shake(on: bool) -> void:
	progress.shake_on = on
	camera.shake_enabled = on
	save_progress()


func choose_hat(id: String) -> bool:
```

**3. `scripts/game/world_builder.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	main.add_child(main.camera)
```
REPLACE:
```gdscript
	main.add_child(main.camera)
	main.camera.shake_enabled = main.progress.shake_on
```

**4. `scripts/ui/ui_root.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	options_panel.volume_changed.connect(Callable(main, "_on_volume_changed"))
```
REPLACE:
```gdscript
	options_panel.volume_changed.connect(Callable(main, "_on_volume_changed"))
	options_panel.shake_toggled.connect(Callable(main, "set_shake"))
```

## Acceptance criteria
- The switch shows `progress.shake_on`; toggling it saves it and sets `camera.shake_enabled`.
- A restarted game starts with the saved setting.
