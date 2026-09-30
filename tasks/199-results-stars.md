---
id: 199-results-stars
status: ready
tests: [tests/acceptance/test_199_results_stars.gd]
files: [scripts/ui/results_panel.gd]
---

# Stars on the results

The results show the shot's star rating right under the title.

**`scripts/ui/results_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var air_label: Label
```
REPLACE:
```gdscript
var air_label: Label
var rating: StarRating
```

Edit 2 - SEARCH:
```gdscript
	title_label = Label.new()
	vbox.add_child(title_label)
```
REPLACE:
```gdscript
	title_label = Label.new()
	vbox.add_child(title_label)
	
	rating = StarRating.new()
	vbox.add_child(rating)
```

Edit 3 - SEARCH:
```gdscript
	title_label.text = "New best!" if is_new_best else "Run complete"
```
REPLACE:
```gdscript
	title_label.text = "New best!" if is_new_best else "Run complete"
	rating.set_rating(StarRating.rating_for(float(result.get("distance", 0.0)), float(result.get("previous_best", 0.0))))
```

## Acceptance criteria
- `results_panel.rating` sits right under `title_label` and rates each shot from the result's distance and previous best.
- A busy first run still fits on screen.
