---
id: 148-challenge-label
status: ready
tests: [tests/acceptance/test_148_challenge_label.gd]
files: [scripts/ui/ui_root.gd]
---

# Today's challenge on the title

The title shows today's challenge at the bottom of the screen, above the tip: "Today's challenge: fly 250 m", or
"Today's challenge: done!" once it is done.

**`scripts/ui/ui_root.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var tip_label: Label
```
REPLACE:
```gdscript
var tip_label: Label
var challenge_label: Label
```

Edit 2 - SEARCH:
```gdscript
	add_child(tip_label)
```
REPLACE:
```gdscript
	add_child(tip_label)
	challenge_label = Label.new()
	challenge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	challenge_label.anchor_left = 0.5
	challenge_label.anchor_right = 0.5
	challenge_label.anchor_top = 1.0
	challenge_label.anchor_bottom = 1.0
	challenge_label.offset_left = -420
	challenge_label.offset_right = 420
	challenge_label.offset_top = -74
	challenge_label.offset_bottom = -46
	challenge_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	challenge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(challenge_label)
```

Edit 3 - SEARCH:
```gdscript
	tip_label.text = Tips.for_date(Daily.today())
```
REPLACE:
```gdscript
	tip_label.text = Tips.for_date(Daily.today())
	challenge_label.visible = title_panel.visible
	var today := Daily.today()
	if progress.challenge_day == Daily.key_for(today):
		challenge_label.text = "Today's challenge: done!"
	else:
		challenge_label.text = "Today's challenge: fly %d m" % roundi(Daily.challenge_distance(today))
```

## Acceptance criteria
- The line is shown on the title only, on screen, between the title panel and the tip.
