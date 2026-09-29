---
id: 080-rogue-ui
status: ready
tests: [tests/acceptance/test_080_rogue_ui.gd]
files: [scripts/ui/ui_root.gd, scripts/ui/title_panel.gd, scripts/game/main.gd]
read: [scripts/ui/rogue_panel.gd, scripts/ui/rogue_over_panel.gd, scripts/ui/hud.gd]
---

# The roguelike is playable from the UI

**1. `scripts/ui/ui_root.gd`** (keep everything):
- Add `var rogue_panel: RoguePanel` and `var rogue_over_panel: RogueOverPanel` after `var toast: Toast`.
- In `_ready()`, right after `add_child(toast)` (so both are themed by the loop below):
  ```gdscript
  	rogue_panel = RoguePanel.new()
  	add_child(rogue_panel)
  	rogue_over_panel = RogueOverPanel.new()
  	add_child(rogue_over_panel)
  ```
- Add this function at the end of the file:
  ```gdscript
  ## Roguelike screens after a shot: the perk choice, or the run-over screen when no lives are left.
  func show_rogue_screens(active: bool, run: RogueRun, outcome: Dictionary, best_rounds: int) -> void:
  	rogue_panel.hide()
  	rogue_over_panel.hide()
  	if not active or run == null:
  		return
  	if run.is_over():
  		rogue_over_panel.show_over(run, best_rounds)
  	else:
  		rogue_panel.show_outcome(outcome, run)
  ```

**2. `scripts/ui/title_panel.gd`** (keep everything):
- Add `signal rogue_pressed` after `signal stats_pressed`, and `var rogue_button: Button` after
  `var stats_button: Button`.
- In `_ready()`, right after `box.add_child(play_button)` (so it is the second button):
  ```gdscript
  	rogue_button = Button.new()
  	rogue_button.text = "Roguelike"
  	rogue_button.pressed.connect(func(): rogue_pressed.emit())
  	box.add_child(rogue_button)
  ```

**3. `scripts/game/main.gd`** (only these edits):
- In `_build_ui()`, right after `title_panel.play_pressed.connect(start_game)`:
  ```gdscript
  	title_panel.rogue_pressed.connect(start_rogue)
  	ui_layer.rogue_panel.perk_chosen.connect(choose_rogue_perk)
  	ui_layer.rogue_over_panel.back_pressed.connect(go_to_title)
  ```
- In `_update_ui()`, replace the two lines
  ```gdscript
  	if hud.visible:
  		hud.update_progress(progress.best_distance, progress.coins)
  ```
  with:
  ```gdscript
  	if hud.visible and mode == "rogue":
  		hud.show_rogue(rogue.goal["text"], rogue.round_number, rogue.lives)
  	elif hud.visible:
  		hud.update_progress(progress.best_distance, progress.coins)
  ```
- In `_update_ui()`, right before the `_update_music()` call at the end:
  ```gdscript
  	ui_layer.show_rogue_screens(state == State.RESULTS and mode == "rogue", rogue, rogue_outcome, progress.best_rogue_round)
  ```

## Acceptance criteria
- The title has a "Roguelike" button that starts a run; the HUD shows "Round 1", "Lives: 3",
  "Goal: Fly at least 40 m".
- After a roguelike shot the perk panel is shown (on screen, themed); its buttons pick a perk and start the next
  shot. When the last life is lost the run-over panel is shown instead, and Back to title returns to classic.
- The classic HUD and results screen are unchanged and never show the roguelike panels.
