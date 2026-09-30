---
id: 115-wardrobe-preview
status: ready
tests: [tests/acceptance/test_115_wardrobe_preview.gd]
files: [scripts/ui/wardrobe_panel.gd]
read: [scripts/ui/title_mascot.gd]
---

# Wardrobe preview

The Wardrobe shows the alien (a bobbing `TitleMascot`, the same one as on the title screen) under its title,
wearing the hat that is on. Choosing a hat updates the preview (main.gd already calls `show_hats` again after a hat is
chosen).

**`scripts/ui/wardrobe_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var close_button: Button
```
REPLACE:
```gdscript
var close_button: Button
var preview: TitleMascot
```

Edit 2 - SEARCH:
```gdscript
	box.add_child(title_label)
```
REPLACE:
```gdscript
	box.add_child(title_label)
	preview = TitleMascot.new()
	box.add_child(preview)
```

Edit 3 - SEARCH:
```gdscript
			button.text = entry["name"]
	show()
```
REPLACE:
```gdscript
			button.text = entry["name"]
	preview.set_hat(progress.hat)
	show()
```

## Acceptance criteria
- `wardrobe_panel.preview` is a TitleMascot right under the title and wears `progress.hat` whenever the hats are shown.
- The Wardrobe still fits on screen.
