---
id: 081-ui-refresh
status: ready
tests: [tests/acceptance/test_081_ui_refresh.gd]
files: [scripts/ui/ui_root.gd, scripts/game/audio_manager.gd, scripts/game/main.gd]
---

# Move screen and music updates out of main.gd

main.gd is close to its 450-line limit and milestone 9 adds features. This is a pure refactor: which screens are
shown for each state moves into UiRoot, and which music plays moves into AudioManager. **Behavior must not
change** - all existing tests must keep passing.

**1. `scripts/ui/ui_root.gd`:** add this function right before `show_rogue_screens()` (keep everything else):
```gdscript
## Shows the screens that belong to main's current state and mode. `main` is the node running scripts/game/main.gd.
func refresh(main: Node) -> void:
	var state: String = main.state_name()
	var rogue_mode: bool = main.mode == "rogue"
	var progress: Progress = main.progress
	hud.visible = state == "AIM" or state == "FLIGHT"
	if hud.visible and rogue_mode:
		hud.show_rogue(main.rogue.goal["text"], main.rogue.round_number, main.rogue.lives)
	elif hud.visible:
		hud.update_progress(progress.best_distance, progress.coins)
	title_panel.visible = state == "TITLE"
	if title_panel.visible:
		title_panel.show_progress(progress.best_distance, progress.total_runs)
	var result: Dictionary = main.last_result
	if state == "RESULTS" and not rogue_mode:
		results_panel.show_result(result, bool(result.get("new_best", false)))
	else:
		results_panel.hide()
	if state == "VICTORY":
		victory_panel.show_victory(progress.total_runs)
	else:
		victory_panel.hide()
	shop_panel.visible = state == "SHOP"
	if shop_panel.visible:
		shop_panel.refresh(progress)
	show_rogue_screens(state == "RESULTS" and rogue_mode, main.rogue, main.rogue_outcome, progress.best_rogue_round)
```

**2. `scripts/game/audio_manager.gd`:** add this function right before `play_music()`:
```gdscript
## The music id for a main.gd state name: "flight" while aiming and flying, "victory" on the victory screen,
## otherwise "menu".
static func music_for_state(state_name: String) -> String:
	match state_name:
		"AIM", "FLIGHT":
			return "flight"
		"VICTORY":
			return "victory"
	return "menu"
```

**3. `scripts/game/main.gd`:**
- Replace the **whole** `_update_ui()` function (its entire body, from `hud.visible = ...` to the `_update_music()`
  call) with:
  ```gdscript
  func _update_ui() -> void:
  	ui_layer.refresh(self)
  	audio.play_music(AudioManager.music_for_state(state_name()))
  ```
- **Delete** the whole `_update_music()` function.
- Keep every call to `_update_ui()` as it is.

After this, main.gd must not contain `results_panel.show_result`, `victory_panel.show_victory`,
`hud.update_progress`, `hud.show_rogue`, `title_panel.show_progress` or `func _update_music`.

## Acceptance criteria
- `AudioManager.music_for_state`: AIM/FLIGHT "flight", VICTORY "victory", everything else "menu".
- `ui_layer.refresh(main)` shows the right screens for main's state; main.gd uses it.
- All existing tests still pass.
