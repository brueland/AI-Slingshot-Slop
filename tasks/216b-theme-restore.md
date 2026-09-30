---
id: 216b-theme-restore
status: ready
tests: [tests/acceptance/test_216b_theme_restore.gd]
files: [scripts/ui/ui_theme.gd]
---

# Theme details

Three theme lines went missing in task 215: the empty focus box on buttons (so a clicked button shows no outline),
the grey text of disabled buttons, and the dark outline of labels (it became too light). This puts them back.

**`scripts/ui/ui_theme.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 keeps its SEARCH line and adds a line before and after it; Edit 2 changes the label outline color. Both are in `build()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
	theme.set_color("font_color", "Button", Color.WHITE)
```
REPLACE:
```gdscript
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	theme.set_color("font_color", "Button", Color.WHITE)
	theme.set_color("font_disabled_color", "Button", Color(0.7, 0.7, 0.75))
```

Edit 2 - SEARCH:
```gdscript
	theme.set_color("font_outline_color", "Label", Color(0.0, 0.0, 0.0, 0.55))
```
REPLACE:
```gdscript
	theme.set_color("font_outline_color", "Label", Color(0, 0, 0, 0.85))
```

## Acceptance criteria
- Buttons have an empty focus box and grey disabled text; labels have a dark (0.85) outline.
