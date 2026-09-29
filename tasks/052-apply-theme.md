---
id: 052-apply-theme
status: ready
tests: [tests/acceptance/test_052_apply_theme.gd]
files: [scripts/game/main.gd]
read: [scripts/ui/ui_theme.gd]
---

# Main: use the UI theme everywhere

Edit `scripts/game/main.gd` (keep everything that works; keep the change small, main.gd must stay under 450
lines).

1. Add `var ui_theme: Theme` next to the other UI vars.
2. In `_build_ui()`, after every panel and the pause label have been added to `ui_layer` (just before
   `state_changed.connect(_on_state_changed)`), build the theme once and give it to every Control on the layer:
   ```gdscript
   ui_theme = UiTheme.build()
   for child in ui_layer.get_children():
   	if child is Control:
   		child.theme = ui_theme
   ```
   Child controls (labels, buttons inside the panels) inherit it automatically.

## Acceptance criteria
- `main.ui_theme` is a Theme and every Control directly on `ui_layer` uses it.
- HUD labels are outlined (outline_size 6), buttons are rounded, panels have the gold border.
- The menus stay centered and on screen (tests/regression/test_ui_on_screen.gd).
