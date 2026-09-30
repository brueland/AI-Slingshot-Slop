---
id: 131-replay-seed
status: ready
tests: [tests/acceptance/test_131_replay_seed.gd]
files: [scripts/ui/rogue_over_panel.gd, scripts/ui/ui_root.gd, scripts/game/main.gd]
---

# Run history and replay on the run-over screen

The run-over screen lists the last runs ("Last runs: 4, 2 rounds") and has a "Play this seed again" button that
starts a new run with the same seed.

**1. `scripts/ui/rogue_over_panel.gd`**: exactly these 4 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
signal back_pressed
```
REPLACE:
```gdscript
signal back_pressed
signal replay_pressed
```

Edit 2 - SEARCH:
```gdscript
var back_button: Button
```
REPLACE:
```gdscript
var back_button: Button
var history_label: Label
var replay_button: Button
```

Edit 3 - SEARCH:
```gdscript
	back_button = Button.new()
```
REPLACE:
```gdscript
	history_label = Label.new()
	history_label.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
	box.add_child(history_label)
	replay_button = Button.new()
	replay_button.text = "Play this seed again"
	replay_button.pressed.connect(func(): replay_pressed.emit())
	box.add_child(replay_button)
	back_button = Button.new()
```

Edit 4 - SEARCH:
```gdscript
func show_over(run: RogueRun, best_rounds: int) -> void:
```
REPLACE:
```gdscript
## "Last runs: 7, 4, 3 rounds" from Progress.rogue_history (newest first); empty when there is none.
func show_history(history: Array) -> void:
	var parts := PackedStringArray()
	for item in history:
		parts.append(str(int(item.get("rounds", 0))))
	history_label.text = "Last runs: %s rounds" % ", ".join(parts) if not parts.is_empty() else ""


func show_over(run: RogueRun, best_rounds: int) -> void:
```

**2. `scripts/ui/ui_root.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	rogue_over_panel.daily_label.text = "Daily run %s - best today: %d rounds" % [daily_key, int(progress.daily_best.get(daily_key, 0))]
```
REPLACE:
```gdscript
	rogue_over_panel.daily_label.text = "Daily run %s - best today: %d rounds" % [daily_key, int(progress.daily_best.get(daily_key, 0))]
	rogue_over_panel.show_history(progress.rogue_history)
```

Edit 2 - SEARCH:
```gdscript
	rogue_over_panel.back_pressed.connect(Callable(main, "go_to_title"))
```
REPLACE:
```gdscript
	rogue_over_panel.back_pressed.connect(Callable(main, "go_to_title"))
	rogue_over_panel.replay_pressed.connect(Callable(main, "replay_rogue_seed"))
```

**3. `scripts/game/main.gd`**: exactly these 1 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
func choose_rogue_perk(id: String) -> bool:
```
REPLACE:
```gdscript
## Plays the last roguelike run's seed again (the run-over screen's button).
func replay_rogue_seed() -> void:
	var run_seed: int = rogue.run_seed
	go_to_title()
	start_rogue(run_seed)


func choose_rogue_perk(id: String) -> bool:
```

## Acceptance criteria
- The run-over screen shows "Last runs: <rounds>, ... rounds" (newest first) and a "Play this seed again" button.
- The button starts a new roguelike run with the same seed; the panel fits on screen.
