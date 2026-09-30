---
id: 143-best-gap
status: ready
tests: [tests/acceptance/test_143_best_gap.gd]
files: [scripts/game/main.gd, scripts/ui/results_panel.gd]
---

# How far from your best

The results say how the run compares to the best: "New best by 12 m!" or "23 m short of your best (140 m)".

**1. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	last_result["new_best"] = last_result["distance"] > previous_best
```
REPLACE:
```gdscript
	last_result["new_best"] = last_result["distance"] > previous_best
	last_result["previous_best"] = previous_best
```

**2. `scripts/ui/results_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var shot_map: ShotMap
```
REPLACE:
```gdscript
var shot_map: ShotMap
var gap_label: Label
```

Edit 2 - SEARCH:
```gdscript
	vbox.add_child(shot_map)
```
REPLACE:
```gdscript
	vbox.add_child(shot_map)
	
	gap_label = Label.new()
	gap_label.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	vbox.add_child(gap_label)
```

Edit 3 - SEARCH:
```gdscript
	shot_map.set_path(path)
```
REPLACE:
```gdscript
	shot_map.set_path(path)
	var previous := float(result.get("previous_best", 0.0))
	var flown := float(result.get("distance", 0.0))
	if is_new_best and previous > 0.0:
		gap_label.text = "New best by %d m!" % roundi(flown - previous)
	elif not is_new_best and previous > 0.0:
		gap_label.text = "%d m short of your best (%d m)" % [roundi(previous - flown), roundi(previous)]
	else:
		gap_label.text = ""
	gap_label.visible = gap_label.text != ""
```

## Acceptance criteria
- `last_result["previous_best"]` is the best before the run.
- A shorter run shows "N m short of your best (B m)", a new best "New best by N m!"; the first run shows neither.
