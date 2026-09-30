---
id: 106-ui-wire
status: ready
tests: [tests/acceptance/test_106_ui_wire.gd]
files: [scripts/ui/ui_root.gd, scripts/game/main.gd]
---

# Move the button wiring out of main.gd

main.gd is close to its 450-line limit and milestone 12 adds features. This is a pure refactor: the lines that
connect the screens' buttons to main.gd move into UiRoot. **Behavior must not change**; all existing tests must
keep passing.

**1. `scripts/ui/ui_root.gd`:** add this function at the end of the file (keep everything else):
```gdscript
## Connects every screen's buttons to main.gd (`main` is the node running scripts/game/main.gd).
func wire(main: Node) -> void:
	results_panel.continue_pressed.connect(Callable(main, "continue_to_shop"))
	victory_panel.continue_pressed.connect(Callable(main, "continue_to_shop"))
	shop_panel.purchase_requested.connect(Callable(main, "buy_upgrade"))
	shop_panel.launch_requested.connect(Callable(main, "leave_shop"))
	title_panel.play_pressed.connect(Callable(main, "start_game"))
	title_panel.rogue_pressed.connect(Callable(main, "start_rogue"))
	title_panel.daily_pressed.connect(Callable(main, "start_daily"))
	rogue_panel.perk_chosen.connect(Callable(main, "choose_rogue_perk"))
	rogue_panel.reroll_pressed.connect(Callable(main, "reroll_perks"))
	pause_menu.resume_pressed.connect(Callable(main, "toggle_pause"))
	pause_menu.quit_pressed.connect(Callable(main, "go_to_title"))
	rogue_over_panel.back_pressed.connect(Callable(main, "go_to_title"))
	title_panel.wardrobe_pressed.connect(func(): wardrobe_panel.show_hats(main.progress))
	wardrobe_panel.hat_chosen.connect(Callable(main, "choose_hat"))
	wardrobe_panel.closed.connect(wardrobe_panel.hide)
	title_panel.reset_pressed.connect(Callable(main, "reset_progress"))
	title_panel.options_pressed.connect(Callable(main, "open_options"))
	title_panel.credits_pressed.connect(credits_panel.show)
	title_panel.stats_pressed.connect(func(): stats_panel.show_stats(main.progress))
	stats_panel.closed.connect(stats_panel.hide)
	credits_panel.closed.connect(credits_panel.hide)
	options_panel.volume_changed.connect(Callable(main, "_on_volume_changed"))
	options_panel.closed.connect(options_panel.hide)
```

**2. `scripts/game/main.gd`:** exactly this one SEARCH/REPLACE edit in `_build_ui()` (nothing else changes).

Edit 1 - SEARCH:
```gdscript
	# Connect signals after all UI components are initialized
	results_panel.continue_pressed.connect(continue_to_shop)
	victory_panel.continue_pressed.connect(continue_to_shop)
	shop_panel.purchase_requested.connect(buy_upgrade)
	shop_panel.launch_requested.connect(leave_shop)
	title_panel.play_pressed.connect(start_game)
	title_panel.rogue_pressed.connect(start_rogue)
	title_panel.daily_pressed.connect(start_daily)
	ui_layer.rogue_panel.perk_chosen.connect(choose_rogue_perk)
	ui_layer.rogue_panel.reroll_pressed.connect(reroll_perks)
	ui_layer.pause_menu.resume_pressed.connect(toggle_pause)
	ui_layer.pause_menu.quit_pressed.connect(go_to_title)
	ui_layer.rogue_over_panel.back_pressed.connect(go_to_title)
	title_panel.wardrobe_pressed.connect(func(): wardrobe_panel.show_hats(progress))
	wardrobe_panel.hat_chosen.connect(choose_hat)
	wardrobe_panel.closed.connect(wardrobe_panel.hide)
	title_panel.reset_pressed.connect(reset_progress)
	title_panel.options_pressed.connect(open_options)
	title_panel.credits_pressed.connect(credits_panel.show)
	title_panel.stats_pressed.connect(func(): stats_panel.show_stats(progress))
	stats_panel.closed.connect(stats_panel.hide)
	credits_panel.closed.connect(credits_panel.hide)
	options_panel.volume_changed.connect(_on_volume_changed)
	options_panel.closed.connect(options_panel.hide)
```
REPLACE:
```gdscript
	ui_layer.wire(self)
```

## Acceptance criteria
- `UiRoot.wire(main)` connects every button signal to the same main.gd function as before.
- main.gd calls `ui_layer.wire(self)` and no longer contains those `connect` lines.
- All existing tests still pass.
