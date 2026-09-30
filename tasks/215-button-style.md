---
id: 215-button-style
status: ready
tests: [tests/acceptance/test_215_button_style.gd, tests/acceptance/test_052_apply_theme.gd, tests/acceptance/test_051_ui_theme.gd]
files: [scripts/ui/ui_theme.gd]
---

# Juicy buttons

Buttons get a chunky look: rounded, with a darker lip along the bottom that shrinks when pressed (the text moves
down with it), outlined text and a soft shadow. A `PrimaryButton` style is orange for the main button. Panels get
rounder corners and a shadow. Two older tests are updated.

**`scripts/ui/ui_theme.gd`**: exactly these 5 SEARCH/REPLACE edit(s). Edits 1, 3 and 4 change the lines shown; Edit 2 changes the button colors and adds PRIMARY_COLORS; Edit 5 adds a function above `build()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
const PANEL_COLOR := Color(0.09, 0.13, 0.24, 0.92)
const BORDER_COLOR := Color(1.0, 0.85, 0.3)
```
REPLACE:
```gdscript
const PANEL_COLOR := Color(0.12, 0.14, 0.32, 0.95)
const BORDER_COLOR := Color(1.0, 0.88, 0.45)
```

Edit 2 - SEARCH:
```gdscript
const BUTTON_COLORS: Dictionary = {
	"normal": Color(0.2, 0.45, 0.85),
	"hover": Color(0.3, 0.55, 0.95),
	"pressed": Color(0.15, 0.35, 0.7),
	"disabled": Color(0.3, 0.3, 0.35, 0.8),
}
```
REPLACE:
```gdscript
const BUTTON_COLORS: Dictionary = {
	"normal": Color(0.22, 0.5, 0.95),
	"hover": Color(0.33, 0.6, 1.0),
	"pressed": Color(0.18, 0.42, 0.85),
	"disabled": Color(0.35, 0.37, 0.45, 0.9),
}
## The main button (PLAY) is warm orange instead of blue.
const PRIMARY_COLORS: Dictionary = {
	"normal": Color(1.0, 0.6, 0.15),
	"hover": Color(1.0, 0.7, 0.3),
	"pressed": Color(0.93, 0.52, 0.1),
	"disabled": Color(0.35, 0.37, 0.45, 0.9),
}
```

Edit 3 - SEARCH:
```gdscript
	panel.set_corner_radius_all(16)
	panel.set_border_width_all(3)
```
REPLACE:
```gdscript
	panel.set_corner_radius_all(22)
	panel.set_border_width_all(4)
	panel.shadow_color = Color(0, 0, 0, 0.35)
	panel.shadow_size = 10
	panel.shadow_offset = Vector2(0, 6)
```

Edit 4 - SEARCH:
```gdscript
	for state in BUTTON_COLORS:
		var box := StyleBoxFlat.new()
		box.bg_color = BUTTON_COLORS[state]
		box.set_corner_radius_all(10)
		box.content_margin_left = 16
		box.content_margin_right = 16
		box.content_margin_top = 8
		box.content_margin_bottom = 8
		theme.set_stylebox(state, "Button", box)
```
REPLACE:
```gdscript
	theme.set_type_variation("PrimaryButton", "Button")
	for state in BUTTON_COLORS:
		theme.set_stylebox(state, "Button", button_box(BUTTON_COLORS[state], state == "pressed"))
		theme.set_stylebox(state, "PrimaryButton", button_box(PRIMARY_COLORS[state], state == "pressed"))
	theme.set_font_size("font_size", "PrimaryButton", 42)
	theme.set_color("font_outline_color", "Button", Color(0.05, 0.08, 0.2, 0.55))
	theme.set_constant("outline_size", "Button", 5)
```

Edit 5 - SEARCH:
```gdscript
static func build() -> Theme:
```
REPLACE:
```gdscript
## A chunky button face: rounded, with a darker lip along the bottom that shrinks when the button is pressed
## (the text moves down with it), and a soft shadow.
static func button_box(color: Color, pressed: bool) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = color.darkened(0.35)
	box.border_width_bottom = 2 if pressed else 6
	box.set_corner_radius_all(16)
	box.content_margin_left = 22
	box.content_margin_right = 22
	box.content_margin_top = 12 if pressed else 8
	box.content_margin_bottom = 8 if pressed else 12
	box.shadow_color = Color(0, 0, 0, 0.25)
	box.shadow_size = 3
	box.shadow_offset = Vector2(0, 3)
	return box


static func build() -> Theme:
```

## Acceptance criteria
- `UiTheme.button_box(color, pressed)` makes the button faces; `PrimaryButton` uses `PRIMARY_COLORS` at font size 42.
- Panels: corner radius 22, a 4 px border and a shadow.
