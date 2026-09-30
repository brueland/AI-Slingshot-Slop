---
id: 167-hover-preview
status: ready
tests: [tests/acceptance/test_167_hover_preview.gd]
files: [scripts/ui/wardrobe_panel.gd]
---

# Try hats on by hovering

In the Wardrobe, hovering an unlocked hat's button shows it on the preview alien; leaving the button shows the worn hat again.

**`scripts/ui/wardrobe_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. (Edit 3 adds a line before `preview.set_hat(progress.hat)` and a new function at the end of the file.)

Edit 1 - SEARCH:
```gdscript
var preview: TitleMascot
```
REPLACE:
```gdscript
var preview: TitleMascot
var worn: String = "none"
```

Edit 2 - SEARCH:
```gdscript
		button.pressed.connect(func(): hat_chosen.emit(id))
```
REPLACE:
```gdscript
		button.pressed.connect(func(): hat_chosen.emit(id))
		button.mouse_entered.connect(func(): preview_hat(id))
		button.mouse_exited.connect(func(): preview_hat(worn))
```

Edit 3 - SEARCH:
```gdscript
	preview.set_hat(progress.hat)
	show()
```
REPLACE:
```gdscript
	worn = progress.hat
	preview.set_hat(progress.hat)
	show()


## Hovering an unlocked hat's button shows it on the preview; leaving shows the worn hat again.
func preview_hat(id: String) -> void:
	var button: Button = hat_buttons.get(id)
	if button != null and not button.disabled:
		preview.set_hat(id)
```

## Acceptance criteria
- `worn` is the hat being worn; `preview_hat(id)` shows unlocked hats only.
- Each hat button's `mouse_entered` previews its hat and `mouse_exited` previews `worn`.
