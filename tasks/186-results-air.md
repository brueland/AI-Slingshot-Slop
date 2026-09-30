---
id: 186-results-air
status: ready
tests: [tests/acceptance/test_186_results_air.gd]
files: [scripts/ui/results_panel.gd]
---

# Air time on the results

The results show the shot's air time right under the bounces.

**`scripts/ui/results_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var balloons_label: Label
```
REPLACE:
```gdscript
var balloons_label: Label
var air_label: Label
```

Edit 2 - SEARCH:
```gdscript
	bounces_label = Label.new()
	vbox.add_child(bounces_label)
```
REPLACE:
```gdscript
	bounces_label = Label.new()
	vbox.add_child(bounces_label)
	
	air_label = Label.new()
	vbox.add_child(air_label)
```

Edit 3 - SEARCH:
```gdscript
	bounces_label.text = "Bounces: %d (+%d)" % [result["bounces"], result["bounce_points"]]
```
REPLACE:
```gdscript
	bounces_label.text = "Bounces: %d (+%d)" % [result["bounces"], result["bounce_points"]]
	air_label.text = "Air time: %.1f s" % float(result.get("air_time", 0.0))
```

## Acceptance criteria
- `air_label` reads `Air time: 3.4 s` (one decimal) and sits right under `bounces_label`.
- A busy first run's results still fit on screen.
