---
id: 038-title-screen
status: ready
tests: [tests/acceptance/test_038_title_screen.gd]
files: [scripts/ui/title_panel.gd, scripts/game/main.gd]
read: [scripts/ui/results_panel.gd]
---

# Title screen

**1. Create `scripts/ui/title_panel.gd`:**
```gdscript
class_name TitlePanel
extends PanelContainer
## The title screen: game name, best distance, Play and Reset progress.

signal play_pressed
signal reset_pressed

var title_label: Label
var best_label: Label
var play_button: Button
var reset_button: Button
var box: VBoxContainer
```
`_ready()`: center it (`PRESET_CENTER`, grow both ways, `custom_minimum_size = Vector2(420, 0)`), add `box`
with: `title_label` text `"Slingshot Skies"` (font size 48: `add_theme_font_size_override("font_size", 48)`), `best_label`, `play_button` text `"Play"`
(pressed -> emit `play_pressed`), `reset_button` text `"Reset progress"` (pressed -> emit `reset_pressed`).
Then `show_progress(0.0, 0)`. Keep `box` as a var; later tasks add buttons to it.

`func show_progress(best: float, runs: int) -> void`: `best_label.text = "Best: %d m in %d runs" % [floori(best), runs]`

**2. Edit `scripts/game/main.gd`:**
- `var title_panel: TitlePanel`, created in `_build_ui()` on `ui_layer`;
  `play_pressed` -> `start_game`, `reset_pressed` -> `reset_progress`.
- In `_update_ui()`: `title_panel.visible = state == State.TITLE` and
  `title_panel.show_progress(progress.best_distance, progress.total_runs)`.
- Add:
  ```gdscript
  func go_to_title() -> void:
  	is_paused = false
  	pause_label.hide()
  	slingshot.cancel_drag()
  	change_state(State.TITLE)
  	_update_ui()


  func reset_progress() -> void:
  	progress = Progress.new()
  	save_progress()
  	_update_ui()
  ```

## Acceptance criteria
- The title panel is visible on the title screen (and hidden otherwise); Play starts the game.
- It shows "Best: 120 m in 3 runs" for that progress; Reset progress clears and saves it.
