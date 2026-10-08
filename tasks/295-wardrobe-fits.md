---
id: 295-wardrobe-fits
status: ready
tests: [tests/acceptance/test_295_wardrobe_fits.gd]
files: [scripts/ui/wardrobe_panel.gd]
---

# The Wardrobe fits the screen

With all ten hats the Wardrobe was 816 px tall and ran off the bottom of a 720 px screen. Its hat buttons now sit in
a two-column GridContainer, so it is about 580 px tall.

**1. `scripts/ui/wardrobe_panel.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Edit 1 adds the grid before the hat loop in `_ready()`; edit 2 puts each hat button in the grid instead of `box`. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
	preview = TitleMascot.new()
	box.add_child(preview)
	for entry in Hats.LIST:
```
REPLACE:
```gdscript
	preview = TitleMascot.new()
	box.add_child(preview)
	# the hats in two columns, so the panel fits the screen with every hat there is
	var grid := GridContainer.new()
	grid.columns = 2
	box.add_child(grid)
	for entry in Hats.LIST:
```

Edit 2 - SEARCH:
```gdscript
		box.add_child(button)
		hat_buttons[id] = button
```
REPLACE:
```gdscript
		grid.add_child(button)
		hat_buttons[id] = button
```

## Acceptance criteria
- The hat buttons are children of a GridContainer with 2 columns; the panel is at most 680 x 1240 px.
