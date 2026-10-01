---
id: 243-boss-panel
status: ready
tests: [tests/acceptance/test_243_boss_panel.gd]
files: [scripts/ui/rogue_panel.gd, scripts/ui/ui_root.gd]
---

# Boss fight results

After a boss fight shot that doesn't beat the boss (task 241), the roguelike panel says how it went: "Boss hit for
5! 7 HP left, 3 shots to go", "No hit! 7 HP left, 2 shots to go", or "Out of shots! The boss heals. Lives left: 2".
The next goal is red like a boss goal's, and the HUD shows the BOSS ROUND! banner during a fight.

**1. `scripts/ui/rogue_panel.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 1 adds two lines in `show_outcome()` after the boss line; edit 2 changes the `goal_label.modulate` line; edit 3 adds `_show_fight_shot()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
	if outcome.get("boss_beaten", false):
		title_label.text = "Boss beaten! +1 life"
```
REPLACE:
```gdscript
	if outcome.get("boss_beaten", false):
		title_label.text = "Boss beaten! +1 life"
	if outcome.get("fight", false) and not outcome.get("met", false):
		_show_fight_shot(outcome, run)
```

Edit 2 - SEARCH:
```gdscript
	goal_label.modulate = Color(1.0, 0.6, 0.6) if run.goal.get("type", "") == "boss" else Color.WHITE
```
REPLACE:
```gdscript
	goal_label.modulate = Color(1.0, 0.6, 0.6) if run.goal.get("type", "") in ["boss", "fight"] else Color.WHITE
```

Edit 3 - SEARCH:
```gdscript
		size_button.set_pressed_no_signal(id == current_run.size_id)
```
REPLACE:
```gdscript
		size_button.set_pressed_no_signal(id == current_run.size_id)


## The title after a boss fight shot that didn't beat it: the damage, the HP and shots left, or out of shots.
func _show_fight_shot(outcome: Dictionary, run: RogueRun) -> void:
	var shots := int(outcome.get("shots_left", 0))
	if shots <= 0:
		title_label.text = "Out of shots! The boss heals. Lives left: %d" % run.lives
		return
	var dealt := int(outcome.get("boss_damage", 0))
	var hit := "Boss hit for %d!" % dealt if dealt > 0 else "No hit!"
	title_label.text = "%s %d HP left, %d shot%s to go" % [hit, int(outcome.get("boss_hp", 0)), shots, "" if shots == 1 else "s"]
```

**2. `scripts/ui/ui_root.gd`**: exactly these 1 SEARCH/REPLACE edit(s). The REPLACE changes only that line in `refresh()`; nothing else changes.

Edit 1 - SEARCH:
```gdscript
		hud.show_boss(str(main.rogue.goal.get("type", "")) == "boss")
```
REPLACE:
```gdscript
		hud.show_boss(str(main.rogue.goal.get("type", "")) in ["boss", "fight"])
```

## Acceptance criteria
- The panel's title for fight shots that didn't beat the boss, as above; the next goal is red for `boss` and `fight` goals.
- `hud.show_boss()` is on for `boss` and `fight` goals.
