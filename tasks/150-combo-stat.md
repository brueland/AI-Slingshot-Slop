---
id: 150-combo-stat
status: ready
tests: [tests/acceptance/test_150_combo_stat.gd]
files: [scripts/ui/stats_panel.gd]
---

# Best combo on the Stats screen

The Stats screen shows "Best combo: xN".

**`scripts/ui/stats_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes. (Edit 3 adds one line right before the line that sets `hats_label.text` in `show_stats()`.)

Edit 1 - SEARCH:
```gdscript
var hats_label: Label
```
REPLACE:
```gdscript
var hats_label: Label
var combo_label: Label
```

Edit 2 - SEARCH:
```gdscript
	vbox.add_child(hats_label)
```
REPLACE:
```gdscript
	vbox.add_child(hats_label)
	combo_label = Label.new()
	vbox.add_child(combo_label)
```

Edit 3 - SEARCH:
```gdscript
	hats_label.text = ```
REPLACE:
```gdscript
	combo_label.text = "Best combo: x%d" % progress.best_combo
	hats_label.text = ```

## Acceptance criteria
- "Best combo: x6" for `progress.best_combo == 6`; the Stats screen still fits on screen.
