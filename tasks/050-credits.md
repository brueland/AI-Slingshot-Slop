---
id: 050-credits
status: ready
tests: [tests/acceptance/test_050_credits.gd]
files: [scripts/ui/credits_panel.gd, scripts/ui/title_panel.gd, scripts/game/main.gd]
read: [CREDITS.md]
---

# Credits screen

The ElvGames music license requires crediting ElvGames; Kenney's assets ask for credit too.

**1. Create `scripts/ui/credits_panel.gd`:**
```gdscript
class_name CreditsPanel
extends PanelContainer
## Asset credits (required by the ElvGames music license). Text comes from res://CREDITS.md.

signal closed

const CREDITS_PATH: String = "res://CREDITS.md"
const FALLBACK: String = "Music by ElvGames. Art and sound effects by Kenney (www.kenney.nl)."

var text_label: Label
var close_button: Button


static func credits_text() -> String:
	if FileAccess.file_exists(CREDITS_PATH):
		return FileAccess.get_file_as_string(CREDITS_PATH)
	return FALLBACK
```
`_ready()`: centered (`custom_minimum_size = Vector2(640, 0)`), a VBoxContainer with a "Credits" title (font
size 32: `add_theme_font_size_override("font_size", 32)`), `text_label` with `text = credits_text()`, `autowrap_mode = TextServer.AUTOWRAP_WORD_SMART`,
`custom_minimum_size = Vector2(600, 0)`, and `close_button` ("Close", pressed -> emit `closed`). End with `hide()`.

**2. `scripts/ui/title_panel.gd`:** `signal credits_pressed`, `var credits_button: Button`: a "Credits" button
added to `box` after Options; pressed -> emit `credits_pressed`.

**3. `scripts/game/main.gd`:** `var credits_panel: CreditsPanel` on `ui_layer` (in `_build_ui()`);
`title_panel.credits_pressed.connect(credits_panel.show)` and `credits_panel.closed.connect(credits_panel.hide)`.

## Acceptance criteria
- The credits text (and the fallback) name ElvGames and Kenney.
- The Credits button on the title opens the panel; Close hides it.
