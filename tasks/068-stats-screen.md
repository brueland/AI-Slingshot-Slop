---
id: 068-stats-screen
status: ready
tests: [tests/acceptance/test_068_stats_screen.gd]
files: [scripts/ui/title_panel.gd, scripts/ui/ui_root.gd, scripts/game/main.gd]
read: [scripts/ui/stats_panel.gd]
---

# Open the stats screen from the title

1. **`scripts/ui/title_panel.gd`:** add `signal stats_pressed` and `var stats_button: Button`: a Button with
   text `"Stats"`, added to `box` right after the Play button; pressed -> emit `stats_pressed`
   (`stats_button.pressed.connect(func(): stats_pressed.emit())`).
2. **`scripts/ui/ui_root.gd`:** `var stats_panel: StatsPanel`, created and added right after `credits_panel`
   (before the theme loop, so it is themed too).
3. **`scripts/game/main.gd`** (keep changes small): `var stats_panel: StatsPanel`; in `_build_ui()`
   `stats_panel = ui_layer.stats_panel`, and connect:
   ```gdscript
   title_panel.stats_pressed.connect(func(): stats_panel.show_stats(progress))
   stats_panel.closed.connect(stats_panel.hide)
   ```

## Acceptance criteria
- The title screen has a "Stats" button that opens the stats panel with the current progress; Close hides it.
- The panel is built by UiRoot, themed, centered, and fits a 720 px screen.
