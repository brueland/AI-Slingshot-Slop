---
id: 202-pause-options
status: ready
tests: [tests/acceptance/test_202_pause_options.gd]
files: [scripts/ui/pause_menu.gd, scripts/ui/ui_root.gd, scripts/game/main.gd]
---

# Options in the pause menu

Milestone 26 makes the menus reachable during play. First, the pause menu gets an Options button that opens the
volume sliders (the same Options panel as on the title). Resuming or quitting to the title closes it.

**1. `scripts/ui/pause_menu.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
signal quit_pressed
```
REPLACE:
```gdscript
signal quit_pressed
signal options_pressed
```

Edit 2 - SEARCH:
```gdscript
var quit_button: Button
```
REPLACE:
```gdscript
var quit_button: Button
var options_button: Button
```

Edit 3 - SEARCH:
```gdscript
	box.add_child(resume_button)
```
REPLACE:
```gdscript
	box.add_child(resume_button)
	options_button = Button.new()
	options_button.text = "Options"
	options_button.pressed.connect(func(): options_pressed.emit())
	box.add_child(options_button)
```

**2. `scripts/ui/ui_root.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	pause_menu.quit_pressed.connect(Callable(main, "go_to_title"))
```
REPLACE:
```gdscript
	pause_menu.quit_pressed.connect(Callable(main, "go_to_title"))
	pause_menu.options_pressed.connect(Callable(main, "open_options"))
```

**3. `scripts/game/main.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 is in `toggle_pause()`, Edit 2 in `go_to_title()`. Each REPLACE keeps the SEARCH line and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	ui_layer.pause_menu.visible = is_paused
```
REPLACE:
```gdscript
	ui_layer.pause_menu.visible = is_paused
	if not is_paused:
		options_panel.hide()
```

Edit 2 - SEARCH:
```gdscript
	ui_layer.pause_menu.hide()
```
REPLACE:
```gdscript
	ui_layer.pause_menu.hide()
	options_panel.hide()
```

## Acceptance criteria
- `pause_menu.options_button` ("Options", between Resume and Quit to title) emits `options_pressed`, wired to `main.open_options`.
- `toggle_pause()` hides the options panel when it resumes; `go_to_title()` hides it too.
