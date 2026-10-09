---
id: 313-wardrobe-bonuses
status: ready
tests: [tests/acceptance/test_313_wardrobe_bonuses.gd]
files: [scripts/ui/wardrobe_panel.gd]
---

# The Wardrobe shows the boosts

Under its preview the Wardrobe now says what the worn hat gives ("Party Hat: +2 points per bounce"), and what an
unlocked hat gives while the mouse is over its button (`bonus_label`, `show_bonus`).

**1. `scripts/ui/wardrobe_panel.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Edit 4 adds a line in `preview_hat()` and `show_bonus()` after it; the others keep the SEARCH lines and add the new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var surprise_button: Button
```
REPLACE:
```gdscript
var surprise_button: Button
## What the shown hat gives (the worn one, or the one under the mouse).
var bonus_label: Label
```

Edit 2 - SEARCH:
```gdscript
	preview = TitleMascot.new()
	box.add_child(preview)
```
REPLACE:
```gdscript
	preview = TitleMascot.new()
	box.add_child(preview)
	bonus_label = Label.new()
	bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bonus_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	box.add_child(bonus_label)
```

Edit 3 - SEARCH:
```gdscript
	worn = progress.hat
	preview.set_hat(progress.hat)
```
REPLACE:
```gdscript
	worn = progress.hat
	preview.set_hat(progress.hat)
	show_bonus(progress.hat)
```

Edit 4 - SEARCH:
```gdscript
	if button != null and not button.disabled:
		preview.set_hat(id)
```
REPLACE:
```gdscript
	if button != null and not button.disabled:
		preview.set_hat(id)
		show_bonus(id)


## Shows what hat `id` gives under the preview.
func show_bonus(id: String) -> void:
	var text := HatBonuses.text(id)
	bonus_label.text = "%s: %s" % [Hats.get_def(id).get("name", ""), text] if text != "" else "No hat: no bonus"
```

## Acceptance criteria
- `bonus_label` shows "<hat>: <boost>" ("No hat: no bonus" for none) for the worn or hovered unlocked hat.
