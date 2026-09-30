---
id: 203-menu-button
status: ready
tests: [tests/acceptance/test_203_menu_button.gd]
files: [scripts/ui/hud.gd, scripts/ui/ui_root.gd]
---

# Menu button

A "Menu (Esc)" button in the bottom-right corner of the HUD pauses the game, so mouse players can reach the pause
menu (Resume, Options, Quit to title).

**1. `scripts/ui/hud.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
## Flight readouts (top left) and progress (top right). Never blocks the mouse.
```
REPLACE:
```gdscript
## Flight readouts (top left) and progress (top right). Never blocks the mouse.

signal menu_pressed
```

Edit 2 - SEARCH:
```gdscript
var course_bar: CourseBar
```
REPLACE:
```gdscript
var course_bar: CourseBar
var menu_button: Button
```

Edit 3 - SEARCH:
```gdscript
	add_child(course_bar)
```
REPLACE:
```gdscript
	add_child(course_bar)
	
	# Menu button in the bottom-right corner: pauses the game (the pause menu has Options and Quit to title)
	menu_button = Button.new()
	menu_button.text = "Menu (Esc)"
	menu_button.focus_mode = Control.FOCUS_NONE
	menu_button.anchor_left = 1.0
	menu_button.anchor_right = 1.0
	menu_button.anchor_top = 1.0
	menu_button.anchor_bottom = 1.0
	menu_button.offset_left = -156
	menu_button.offset_right = -16
	menu_button.offset_top = -56
	menu_button.offset_bottom = -16
	menu_button.pressed.connect(func(): menu_pressed.emit())
	add_child(menu_button)
```

**2. `scripts/ui/ui_root.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	pause_menu.resume_pressed.connect(Callable(main, "toggle_pause"))
```
REPLACE:
```gdscript
	pause_menu.resume_pressed.connect(Callable(main, "toggle_pause"))
	hud.menu_pressed.connect(Callable(main, "toggle_pause"))
```

## Acceptance criteria
- `hud.menu_button` emits `hud.menu_pressed`, wired to `main.toggle_pause`; it never takes keyboard focus.
- It sits in the bottom-right corner, on screen and clear of the slingshot and the course bar.
