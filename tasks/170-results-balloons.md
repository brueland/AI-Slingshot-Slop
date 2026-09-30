---
id: 170-results-balloons
status: ready
tests: [tests/acceptance/test_170_results_balloons.gd]
files: [scripts/ui/results_panel.gd]
---

# Balloons on the results

The results screen shows "Balloons popped: N" (pink, under the new-hat line) when the shot popped any balloons.

**`scripts/ui/results_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var hats_label: Label
```
REPLACE:
```gdscript
var hats_label: Label
var balloons_label: Label
```

Edit 2 - SEARCH:
```gdscript
	vbox.add_child(hats_label)
```
REPLACE:
```gdscript
	vbox.add_child(hats_label)
	
	balloons_label = Label.new()
	balloons_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.85))
	balloons_label.visible = false
	vbox.add_child(balloons_label)
```

Edit 3 - SEARCH:
```gdscript
	hats_label.visible = not new_hats.is_empty()
```
REPLACE:
```gdscript
	hats_label.visible = not new_hats.is_empty()
	var popped := int(result.get("balloons", 0))
	balloons_label.text = "Balloons popped: %d" % popped
	balloons_label.visible = popped > 0
```

## Acceptance criteria
- `balloons_label` shows `Balloons popped: N` from the result's `balloons`, hidden when it is 0.
- The results still fit on screen.
