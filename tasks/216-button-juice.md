---
id: 216-button-juice
status: ready
tests: [tests/acceptance/test_216_button_juice.gd]
files: [scripts/ui/ui_theme.gd, scripts/ui/ui_root.gd]
---

# Springy buttons

Every button grows a little under the mouse and squashes while it is held down (a short springy tween).

**1. `scripts/ui/ui_theme.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds two functions above `build()`; Edit 2 adds two constants. Each REPLACE keeps its SEARCH lines; nothing else changes.

Edit 1 - SEARCH:
```gdscript
static func build() -> Theme:
```
REPLACE:
```gdscript
## Makes a button springy: it grows a little under the mouse and squashes while it is held down.
static func add_juice(button: Button) -> void:
	button.pivot_offset = button.size / 2.0
	button.resized.connect(func(): button.pivot_offset = button.size / 2.0)
	button.mouse_entered.connect(func(): _spring(button, HOVER_SCALE))
	button.mouse_exited.connect(func(): _spring(button, 1.0))
	button.button_down.connect(func(): _spring(button, PRESS_SCALE))
	button.button_up.connect(func(): _spring(button, HOVER_SCALE if button.is_hovered() else 1.0))


static func _spring(button: Button, to: float) -> void:
	if not button.is_inside_tree():
		return
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE * to, 0.12)


static func build() -> Theme:
```

Edit 2 - SEARCH:
```gdscript
const FONT_PATH: String = "res://assets/fonts/Fredoka.ttf"
```
REPLACE:
```gdscript
const FONT_PATH: String = "res://assets/fonts/Fredoka.ttf"
const HOVER_SCALE: float = 1.06
const PRESS_SCALE: float = 0.94
```

**2. `scripts/ui/ui_root.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	ui_theme = UiTheme.build()
	for child in get_children():
		if child is Control:
			child.theme = ui_theme
```
REPLACE:
```gdscript
	ui_theme = UiTheme.build()
	for child in get_children():
		if child is Control:
			child.theme = ui_theme
	for button in find_children("*", "Button", true, false):
		UiTheme.add_juice(button)
```

## Acceptance criteria
- `UiTheme.add_juice(button)`: scale 1.06 under the mouse, 0.94 while held, around the button's center.
- UiRoot adds it to every button once the UI is built.
