---
id: 254-star-boxes
status: ready
tests: [tests/acceptance/test_254_star_boxes.gd]
files: [scripts/ui/perk_chips.gd, scripts/ui/hud.gd, scripts/ui/ui_root.gd]
---

# Stars on the HUD

The HUD's perk boxes (milestone 32) also show the run's stars: a gold "Stars 23" box and a gold box for each star
boost with its count ("Speed+ x4"), after the perks. PerkChips gets a general `_box(text, badge_text, color)` that
`_chip` now uses; `show_perks` takes the stars and boosts too.

**1. `scripts/ui/perk_chips.gd`**: exactly these 6 SEARCH/REPLACE edit(s). Edit 2 changes the comment and the signature of `show_perks()`; edit 3 replaces its last line with the star boxes; edit 4 adds the star texts in `chip_texts()`; edit 5 replaces `_chip()` with a one-line version and the general `_box()` (the same code with `text`, `badge_text` and `color`); the others keep the SEARCH lines and add the new ones. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var order: Array[String] = []
```
REPLACE:
```gdscript
var order: Array[String] = []
## The run's stars and their boosts (boost id -> how many), shown after the perks in gold.
var star_count: int = 0
var boost_counts: Dictionary = {}
```

Edit 2 - SEARCH:
```gdscript
## Shows a box for every perk in `perk_ids`; a perk picked again raises its count instead of adding a box.
func show_perks(perk_ids: Array) -> void:
```
REPLACE:
```gdscript
## Shows a box for every perk in `perk_ids` (a perk picked again raises its count instead of adding a box), then
## gold boxes for the run's `stars` and their `boosts` (boost id -> how many).
func show_perks(perk_ids: Array, stars: int = 0, boosts: Dictionary = {}) -> void:
```

Edit 3 - SEARCH:
```gdscript
	for id in order:
		add_child(_chip(id, counts[id]))
	visible = not order.is_empty()
```
REPLACE:
```gdscript
	for id in order:
		add_child(_chip(id, counts[id]))
	star_count = stars
	boost_counts = boosts.duplicate()
	if stars > 0:
		add_child(_box("Stars", str(stars), STAR_COLOR))
	for boost in StarBoosts.LIST:
		if int(boosts.get(boost["id"], 0)) > 0:
			add_child(_box(boost["name"], "x%d" % int(boosts[boost["id"]]), STAR_COLOR))
	visible = not order.is_empty() or stars > 0
```

Edit 4 - SEARCH:
```gdscript
		out.append("%s x%d" % [RoguePerks.get_def(id).get("name", id), counts[id]])
	return out
```
REPLACE:
```gdscript
		out.append("%s x%d" % [RoguePerks.get_def(id).get("name", id), counts[id]])
	if star_count > 0:
		out.append("Stars %d" % star_count)
	for boost in StarBoosts.LIST:
		if int(boost_counts.get(boost["id"], 0)) > 0:
			out.append("%s x%d" % [boost["name"], int(boost_counts[boost["id"]])])
	return out
```

Edit 5 - SEARCH:
```gdscript
func _chip(id: String, count: int) -> PanelContainer:
	var box := PanelContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_stylebox_override("panel", _style(COLORS.get(id, Color(0.4, 0.4, 0.4)), 6, 7.0, 3.0))
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 5)
	box.add_child(row)
	row.add_child(_label(str(RoguePerks.get_def(id).get("name", id)), Color.WHITE))
	var badge := PanelContainer.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_theme_stylebox_override("panel", _style(Color(0.0, 0.0, 0.0, 0.35), 5, 4.0, 4.0))
	badge.add_child(_label("x%d" % count, Color(1.0, 0.86, 0.3)))
	row.add_child(badge)
	return box


```
REPLACE:
```gdscript
func _chip(id: String, count: int) -> PanelContainer:
	return _box(str(RoguePerks.get_def(id).get("name", id)), "x%d" % count, COLORS.get(id, Color(0.4, 0.4, 0.4)))


## A colored box with `text` and a dark badge with `badge_text`.
func _box(text: String, badge_text: String, color: Color) -> PanelContainer:
	var box := PanelContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_stylebox_override("panel", _style(color, 6, 7.0, 3.0))
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 5)
	box.add_child(row)
	row.add_child(_label(text, Color.WHITE))
	var badge := PanelContainer.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_theme_stylebox_override("panel", _style(Color(0.0, 0.0, 0.0, 0.35), 5, 4.0, 4.0))
	badge.add_child(_label(badge_text, Color(1.0, 0.86, 0.3)))
	row.add_child(badge)
	return box


```

Edit 6 - SEARCH:
```gdscript
	"feather": Color(0.34, 0.42, 0.78), "steady": Color(0.52, 0.33, 0.72),
}
```
REPLACE:
```gdscript
	"feather": Color(0.34, 0.42, 0.78), "steady": Color(0.52, 0.33, 0.72),
}
## The gold of the star boxes.
const STAR_COLOR := Color(0.7, 0.55, 0.08)
```

**2. `scripts/ui/hud.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes `show_perks()` (it passes the stars on); nothing else in hud.gd changes.

Edit 1 - SEARCH:
```gdscript
## Roguelike: the perks taken so far as boxes with counts, under the goal (hidden when there are none).
func show_perks(perk_ids: Array) -> void:
	perk_chips.show_perks(perk_ids)
```
REPLACE:
```gdscript
## Roguelike: the perks taken so far as boxes with counts, under the goal, then the run's stars and star boosts.
func show_perks(perk_ids: Array, stars: int = 0, boosts: Dictionary = {}) -> void:
	perk_chips.show_perks(perk_ids, stars, boosts)
```

**3. `scripts/ui/ui_root.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes that one call in `refresh()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
		hud.show_perks(main.rogue.perks)
```
REPLACE:
```gdscript
		hud.show_perks(main.rogue.perks, main.rogue.stars_total, main.rogue.star_boosts)
```

## Acceptance criteria
- `PerkChips.show_perks(ids, stars, boosts)`: the perk boxes, then "Stars N" and one "Speed+ xN" box per boost (in StarBoosts.LIST order), in gold.
- `chip_texts()` lists them all; the HUD shows the rogue run's `stars_total` and `star_boosts`.
