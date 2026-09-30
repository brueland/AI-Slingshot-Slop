---
id: 218-hud-panels
status: ready
tests: [tests/acceptance/test_218_hud_panels.gd]
files: [scripts/ui/ui_theme.gd, scripts/ui/hud.gd]
---

# HUD panels

The HUD's readouts are grouped in two outlined glass panels: the flight readouts on the left (with the height bar
beside them) and the progress on the right.

**1. `scripts/ui/ui_theme.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE adds a function above `build()` and keeps its first line; nothing else changes.

Edit 1 - SEARCH:
```gdscript
static func build() -> Theme:
```
REPLACE:
```gdscript
## The HUD's group boxes: dark glass with a thin light outline.
static func hud_panel() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.05, 0.07, 0.2, 0.55)
	box.border_color = Color(1, 1, 1, 0.3)
	box.set_border_width_all(2)
	box.set_corner_radius_all(14)
	box.content_margin_left = 14
	box.content_margin_right = 14
	box.content_margin_top = 8
	box.content_margin_bottom = 10
	return box


static func build() -> Theme:
```

**2. `scripts/ui/hud.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edits 1 and 3 put the left and right columns inside panels (the columns keep their names and contents); Edit 2 moves the height bar next to the left column; Edit 4 makes the Menu button grow left and up from its corner (the new font is wider). Nothing else changes.

Edit 1 - SEARCH:
```gdscript
	var left_container := VBoxContainer.new()
	left_container.position = Vector2(16, 16)
	add_child(left_container)
```
REPLACE:
```gdscript
	var left_panel := PanelContainer.new()
	left_panel.position = Vector2(12, 12)
	left_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_panel.add_theme_stylebox_override("panel", UiTheme.hud_panel())
	add_child(left_panel)
	var left_row := HBoxContainer.new()
	left_row.add_theme_constant_override("separation", 14)
	left_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_panel.add_child(left_row)
	var left_container := VBoxContainer.new()
	left_row.add_child(left_container)
```

Edit 2 - SEARCH:
```gdscript
	altitude_bar = AltitudeBar.new()
	left_container.add_child(altitude_bar)
```
REPLACE:
```gdscript
	altitude_bar = AltitudeBar.new()
	left_row.add_child(altitude_bar)
```

Edit 3 - SEARCH:
```gdscript
	var right_container := VBoxContainer.new()
	right_container.anchor_left = 1.0
	right_container.anchor_right = 1.0
	right_container.offset_left = -320
	right_container.offset_right = -16
	right_container.offset_top = 16
	add_child(right_container)
```
REPLACE:
```gdscript
	var right_panel := PanelContainer.new()
	right_panel.anchor_left = 1.0
	right_panel.anchor_right = 1.0
	right_panel.offset_left = -344
	right_panel.offset_right = -12
	right_panel.offset_top = 12
	right_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_panel.add_theme_stylebox_override("panel", UiTheme.hud_panel())
	add_child(right_panel)
	var right_container := VBoxContainer.new()
	right_panel.add_child(right_container)
```

Edit 4 - SEARCH:
```gdscript
	menu_button.offset_bottom = -16
```
REPLACE:
```gdscript
	menu_button.offset_bottom = -16
	menu_button.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	menu_button.grow_vertical = Control.GROW_DIRECTION_BEGIN
```

## Acceptance criteria
- `UiTheme.hud_panel()` is the panel style (dark glass, 2 px light outline).
- The left and right columns sit in PanelContainers that never block the mouse; the Menu button grows left from its corner.
