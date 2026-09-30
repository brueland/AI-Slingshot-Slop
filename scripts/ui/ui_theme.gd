class_name UiTheme
extends RefCounted
## The game's look for all UI: rounded dark-blue panels with a gold border, blue buttons, outlined text.

const PANEL_COLOR := Color(0.09, 0.13, 0.24, 0.92)
const BORDER_COLOR := Color(1.0, 0.85, 0.3)
const FONT_PATH: String = "res://assets/fonts/Fredoka.ttf"
const LOGO_FONT_PATH: String = "res://assets/fonts/LilitaOne-Regular.ttf"
const BUTTON_COLORS: Dictionary = {
	"normal": Color(0.2, 0.45, 0.85),
	"hover": Color(0.3, 0.55, 0.95),
	"pressed": Color(0.15, 0.35, 0.7),
	"disabled": Color(0.3, 0.3, 0.35, 0.8),
}


## Fredoka at a weight from 400 (regular) to 700 (bold): the game's font.
static func game_font(weight: int) -> FontVariation:
	var font := FontVariation.new()
	font.base_font = load(FONT_PATH)
	font.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
	return font


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
	panel.set_corner_radius_all(16)
	panel.set_border_width_all(3)
	panel.border_color = BORDER_COLOR
	panel.set_content_margin_all(24)
	theme.set_stylebox("panel", "PanelContainer", panel)
	for state in BUTTON_COLORS:
		var box := StyleBoxFlat.new()
		box.bg_color = BUTTON_COLORS[state]
		box.set_corner_radius_all(10)
		box.content_margin_left = 16
		box.content_margin_right = 16
		box.content_margin_top = 8
		box.content_margin_bottom = 8
		theme.set_stylebox(state, "Button", box)
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	theme.set_color("font_color", "Button", Color.WHITE)
	theme.set_color("font_disabled_color", "Button", Color(0.7, 0.7, 0.75))
	theme.set_color("font_color", "Label", Color.WHITE)
	theme.set_color("font_outline_color", "Label", Color(0, 0, 0, 0.85))
	theme.set_constant("outline_size", "Label", 6)
	return theme
