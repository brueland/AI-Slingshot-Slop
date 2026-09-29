---
id: 061-ui-root
status: ready
tests: [tests/acceptance/test_061_ui_root.gd]
files: [scripts/ui/ui_root.gd, scripts/game/main.gd]
---

# Refactor: move UI building out of main.gd into UiRoot

main.gd is close to its 450-line limit. Move the code that **builds** the UI into a new CanvasLayer script;
main.gd keeps its variables and signal connections. Nothing may change for the player; all existing tests keep
passing.

**1. Create `scripts/ui/ui_root.gd`:**
```gdscript
class_name UiRoot
extends CanvasLayer
## Builds and themes every UI control. main.gd keeps references to them and connects their signals.

var ui_theme: Theme
var hud: Hud
var results_panel: ResultsPanel
var victory_panel: VictoryPanel
var shop_panel: ShopPanel
var title_panel: TitlePanel
var pause_label: Label
var options_panel: OptionsPanel
var credits_panel: CreditsPanel


func _ready() -> void:
	hud = Hud.new()
	add_child(hud)
	results_panel = ResultsPanel.new()
	add_child(results_panel)
	victory_panel = VictoryPanel.new()
	add_child(victory_panel)
	shop_panel = ShopPanel.new()
	add_child(shop_panel)
	title_panel = TitlePanel.new()
	add_child(title_panel)
	pause_label = Label.new()
	pause_label.text = "Paused - press Esc to resume"
	pause_label.add_theme_font_size_override("font_size", 32)
	pause_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pause_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	pause_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	pause_label.hide()
	add_child(pause_label)
	options_panel = OptionsPanel.new()
	add_child(options_panel)
	credits_panel = CreditsPanel.new()
	add_child(credits_panel)
	ui_theme = UiTheme.build()
	for child in get_children():
		if child is Control:
			child.theme = ui_theme
```

**2. `scripts/game/main.gd`:** change `var ui_layer: CanvasLayer` to `var ui_layer: UiRoot`. In `_build_ui()`,
replace everything that creates the layer, the panels, the pause label and the theme (the `.new()` calls, the
pause-label lines and the theme loop) with:
```gdscript
	ui_layer = UiRoot.new()
	add_child(ui_layer)
	ui_theme = ui_layer.ui_theme
	hud = ui_layer.hud
	results_panel = ui_layer.results_panel
	victory_panel = ui_layer.victory_panel
	shop_panel = ui_layer.shop_panel
	title_panel = ui_layer.title_panel
	pause_label = ui_layer.pause_label
	options_panel = ui_layer.options_panel
	credits_panel = ui_layer.credits_panel
```
Keep all the `.connect(...)` lines, `state_changed.connect(_on_state_changed)` and `_update_ui()` after it.

## Acceptance criteria
- UiRoot builds all eight UI parts as its children and themes them.
- main.ui_layer is a UiRoot and main's UI variables point at its parts; buttons still work.
- main.gd no longer contains `Hud.new()`, `ResultsPanel.new()`, `ShopPanel.new()`, `Label.new()` or `UiTheme.build()`.
