---
id: 188-results-best-air
status: ready
tests: [tests/acceptance/test_188_results_best_air.gd]
files: [scripts/ui/results_panel.gd]
---

# Best air time on the results

The results' air time line also shows the best air time.

**`scripts/ui/results_panel.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	air_label.text = "Air time: %.1f s" % float(result.get("air_time", 0.0))
```
REPLACE:
```gdscript
	air_label.text = "Air time: %.1f s" % float(result.get("air_time", 0.0))
	if float(result.get("best_air_time", 0.0)) > 0.0:
		air_label.text += "   (best %.1f s)" % float(result["best_air_time"])
```

## Acceptance criteria
- `air_label` reads `Air time: 2.3 s   (best 4.0 s)`, or just `Air time: 2.3 s` when the result has no best.
