class_name UiTheme
extends RefCounted
## The game's look for all UI: rounded dark-blue panels with a gold border, blue buttons, outlined text.

const PANEL_COLOR := Color(0.12, 0.14, 0.32, 0.95)
const BORDER_COLOR := Color(1.0, 0.88, 0.45)
const FONT_PATH: String = "res://assets/fonts/Fredoka.ttf"
const LOGO_FONT_PATH: String = "res://assets/fonts/LilitaOne-Regular.ttf"
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


## Fredoka at a weight from 400 (regular) to 700 (bold): the game's font.
static func game_font(weight: int) -> FontVariation:
	var font := FontVariation.new()
	font.base_font = load(FONT_PATH)
	font.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
	return font


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
	var theme := Theme.new()
	theme.default_font = game_font(600)
	theme.default_font_size = 22
	theme.set_type_variation("LogoLabel", "Label")
	theme.set_font("font", "LogoLabel", load(LOGO_FONT_PATH))
	theme.set_font_size("font_size", "LogoLabel", 76)
	theme.set_color("font_color", "LogoLabel", Color(1.0, 0.86, 0.3))
	theme.set_color("font_outline_color", "LogoLabel", Color(0.16, 0.08, 0.3))
	theme.set_constant("outline_size", "LogoLabel", 16)
	theme.set_color("font_shadow_color", "LogoLabel", Color(0, 0, 0, 0.35))
	theme.set_constant("shadow_offset_y", "LogoLabel", 6)
	var panel := StyleBoxFlat.new()
	panel.bg_color = PANEL_COLOR
	panel.set_corner_radius_all(22)
	panel.set_border_width_all(4)
	panel.border_color = BORDER_COLOR
	panel.set_content_margin_all(24)
	panel.shadow_color = Color(0, 0, 0, 0.35)
	panel.shadow_size = 10
	panel.shadow_offset = Vector2(0, 6)
	theme.set_stylebox("panel", "PanelContainer", panel)
	theme.set_type_variation("PrimaryButton", "Button")
	for state in BUTTON_COLORS:
		theme.set_stylebox(state, "Button", button_box(BUTTON_COLORS[state], state == "pressed"))
		theme.set_stylebox(state, "PrimaryButton", button_box(PRIMARY_COLORS[state], state == "pressed"))
	theme.set_font_size("font_size", "PrimaryButton", 42)
	theme.set_color("font_color", "Button", Color.WHITE)
	theme.set_color("font_outline_color", "Button", Color(0.05, 0.08, 0.2, 0.55))
	theme.set_constant("outline_size", "Button", 5)
	theme.set_color("font_color", "Label", Color.WHITE)
	theme.set_constant("outline_size", "Label", 6)
	theme.set_color("font_outline_color", "Label", Color(0.0, 0.0, 0.0, 0.5))
	return theme
