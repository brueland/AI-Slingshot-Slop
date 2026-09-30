---
id: 214-fonts
status: ready
tests: [tests/acceptance/test_214_fonts.gd, tests/acceptance/test_051_ui_theme.gd]
files: [scripts/ui/ui_theme.gd, scripts/ui/title_panel.gd]
---

# A game font

Milestone 28 gives the menus a proper game look. First, the font: the game uses Fredoka (a rounded font, at
weight 600) everywhere, and the title logo uses Lilita One (gold, with a thick outline). The font files and their
licenses are already in `assets/fonts/`. One older test is updated for the new font size.

**1. `scripts/ui/ui_theme.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edits 1-2 keep their first SEARCH line where shown and add new ones (Edit 2 replaces the font size line); Edit 3 adds a function above `build()`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
const BORDER_COLOR := Color(1.0, 0.85, 0.3)
```
REPLACE:
```gdscript
const BORDER_COLOR := Color(1.0, 0.85, 0.3)
const FONT_PATH: String = "res://assets/fonts/Fredoka.ttf"
const LOGO_FONT_PATH: String = "res://assets/fonts/LilitaOne-Regular.ttf"
```

Edit 2 - SEARCH:
```gdscript
	theme.default_font_size = 20
```
REPLACE:
```gdscript
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
```

Edit 3 - SEARCH:
```gdscript
static func build() -> Theme:
```
REPLACE:
```gdscript
## Fredoka at a weight from 400 (regular) to 700 (bold): the game's font.
static func game_font(weight: int) -> FontVariation:
	var font := FontVariation.new()
	font.base_font = load(FONT_PATH)
	font.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
	return font


static func build() -> Theme:
```

**2. `scripts/ui/title_panel.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE swaps the title's font size line for the logo style; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	title_label.add_theme_font_size_override("font_size", 48)
```
REPLACE:
```gdscript
	title_label.theme_type_variation = "LogoLabel"
```

## Acceptance criteria
- `UiTheme.game_font(weight)` gives Fredoka at that weight; the theme's default font is weight 600, size 22.
- The `LogoLabel` style (Lilita One, 76 px, gold, outlined) is used by the title's logo.
