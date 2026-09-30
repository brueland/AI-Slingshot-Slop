---
id: 119-boss-panel
status: ready
tests: [tests/acceptance/test_119_boss_panel.gd]
files: [scripts/ui/rogue_panel.gd]
---

# Boss rounds on the perk panel

The perk panel shows a boss goal in red and says "Boss beaten! +1 life" after one is beaten.

**`scripts/ui/rogue_panel.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	goal_label.text = "Next goal: %s" % run.goal.get("text", "")
```
REPLACE:
```gdscript
	goal_label.text = "Next goal: %s" % run.goal.get("text", "")
	if outcome.get("boss_beaten", false):
		title_label.text = "Boss beaten! +1 life"
	goal_label.modulate = Color(1.0, 0.6, 0.6) if run.goal.get("type", "") == "boss" else Color.WHITE
```

## Acceptance criteria
- A boss goal's "Next goal: BOSS: ..." line is red (`Color(1.0, 0.6, 0.6)`); normal goals are white.
- After beating a boss the title reads "Boss beaten! +1 life".
