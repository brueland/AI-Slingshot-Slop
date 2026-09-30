---
id: 197-title-greeting
status: ready
tests: [tests/acceptance/test_197_title_greeting.gd]
files: [scripts/ui/title_panel.gd]
---

# Greeting on the title

The title screen shows today's holiday greeting (if any) right under the game's name.

**`scripts/ui/title_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edits 1-2 keep their SEARCH lines and add new ones; Edit 3 adds a function above `set_mascot_hat()` and keeps its first line. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var mascot: TitleMascot
```
REPLACE:
```gdscript
var mascot: TitleMascot
var greeting_label: Label
```

Edit 2 - SEARCH:
```gdscript
	title_label.add_theme_font_size_override("font_size", 48)
	box.add_child(title_label)
```
REPLACE:
```gdscript
	title_label.add_theme_font_size_override("font_size", 48)
	box.add_child(title_label)
	
	greeting_label = Label.new()
	greeting_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.9))
	greeting_label.hide()
	box.add_child(greeting_label)
	show_greeting(Greetings.today())
```

Edit 3 - SEARCH:
```gdscript
func set_mascot_hat(id: String) -> void:
```
REPLACE:
```gdscript
## Shows a holiday greeting under the title ("" hides it).
func show_greeting(text: String) -> void:
	greeting_label.text = text
	greeting_label.visible = text != ""

func set_mascot_hat(id: String) -> void:
```

## Acceptance criteria
- `greeting_label` sits right under `title_label`; `show_greeting(text)` shows it, "" hides it; `_ready` uses `Greetings.today()`.
