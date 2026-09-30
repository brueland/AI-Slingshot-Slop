---
id: 132-hud-perks
status: ready
tests: [tests/acceptance/test_132_hud_perks.gd]
files: [scripts/core/rogue_perks.gd, scripts/ui/hud.gd, scripts/ui/ui_root.gd]
---

# Perks on the HUD

The roguelike HUD lists the perks taken so far, like "Perks: Stronger Bands x2, Rocket"; classic hides it.

**1. `scripts/core/rogue_perks.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
static func get_def(id: String) -> Dictionary:
```
REPLACE:
```gdscript
## The perks taken so far, like "Stronger Bands x2, Rocket" (in the order first taken); "" when none.
static func summary(perk_ids: Array) -> String:
	var order: Array[String] = []
	var counts := {}
	for id in perk_ids:
		var key := str(id)
		if not counts.has(key):
			order.append(key)
		counts[key] = int(counts.get(key, 0)) + 1
	var parts := PackedStringArray()
	for key in order:
		var perk_name := str(get_def(key).get("name", key))
		parts.append(perk_name if int(counts[key]) == 1 else "%s x%d" % [perk_name, int(counts[key])])
	return ", ".join(parts)


static func get_def(id: String) -> Dictionary:
```

**2. `scripts/ui/hud.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
var hint_label: Label
```
REPLACE:
```gdscript
var hint_label: Label
var perks_label: Label
```

Edit 2 - SEARCH:
```gdscript
	goal_label = Label.new()
	right_container.add_child(goal_label)
	goal_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	goal_label.add_theme_font_size_override("font_size", 22)
```
REPLACE:
```gdscript
	goal_label = Label.new()
	right_container.add_child(goal_label)
	goal_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	goal_label.add_theme_font_size_override("font_size", 22)
	
	perks_label = Label.new()
	perks_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	perks_label.custom_minimum_size = Vector2(300, 0)
	perks_label.add_theme_font_size_override("font_size", 16)
	perks_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	perks_label.hide()
	right_container.add_child(perks_label)
```

Edit 3 - SEARCH:
```gdscript
func hide_hint() -> void:
```
REPLACE:
```gdscript
## Roguelike: the perks taken so far, under the goal (hidden when `text` is empty).
func show_perks(text: String) -> void:
	perks_label.text = "Perks: " + text
	perks_label.visible = text != ""


func hide_hint() -> void:
```

**3. `scripts/ui/ui_root.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
		hud.show_rogue(main.rogue.goal["text"], main.rogue.round_number, main.rogue.lives)
```
REPLACE:
```gdscript
		hud.show_rogue(main.rogue.goal["text"], main.rogue.round_number, main.rogue.lives)
		hud.show_perks(RoguePerks.summary(main.rogue.perks))
```

Edit 2 - SEARCH:
```gdscript
		hud.update_progress(progress.best_distance, progress.coins)
```
REPLACE:
```gdscript
		hud.update_progress(progress.best_distance, progress.coins)
		hud.show_perks("")
```

## Acceptance criteria
- `RoguePerks.summary(perks)` names each perk once, in the order first taken, with "xN" for repeats; "" for none.
- The HUD shows "Perks: ..." in the roguelike when there are perks, and hides it otherwise.
