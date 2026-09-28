---
id: 035-main-ui
status: ready
tests: [tests/acceptance/test_035_main_ui.gd]
files: [scripts/game/main.gd]
read: [scripts/ui/hud.gd, scripts/ui/results_panel.gd, scripts/ui/shop_panel.gd]
---

# Main: HUD, results and shop on screen

Edit `scripts/game/main.gd` (keep everything that works). Put the UI on a CanvasLayer and show each panel in
its state.

1. Vars: `ui_layer: CanvasLayer`, `hud: Hud`, `results_panel: ResultsPanel`, `shop_panel: ShopPanel`.
2. At the end of `_ready()`, call a new `_build_ui()` that creates `ui_layer = CanvasLayer.new()` (child of
   main) and adds `hud`, `results_panel` and `shop_panel` to it. Connect:
   `results_panel.continue_pressed` -> `continue_to_shop`, `shop_panel.purchase_requested` -> `buy_upgrade`,
   `shop_panel.launch_requested` -> `leave_shop`. Then `state_changed.connect(_on_state_changed)` and call
   `_update_ui()` once.
3. `_on_state_changed(_new_state: int)` calls `_update_ui()`, which does:
   - `hud.visible = state == State.AIM or state == State.FLIGHT`; `hud.update_progress(progress.best_distance, progress.coins)`
   - RESULTS: `results_panel.show_result(last_result, bool(last_result.get("new_best", false)))`; any other state: `results_panel.hide()`
   - `shop_panel.visible = state == State.SHOP`; in SHOP also `shop_panel.refresh(progress)`
4. In `_finish_run()`, remember `var previous_best := progress.best_distance` before `record_run`, then set
   `last_result["new_best"] = last_result["distance"] > previous_best`.
5. In `advance()` during FLIGHT, after syncing the views:
   `hud.update_flight(session.sim.distance(), session.sim.position.y, session.tracker.stars_collected, session.sim.boost_charges)`.
6. `buy_upgrade(id)`: after a successful purchase call `shop_panel.refresh(progress)` (still return true/false).

## Acceptance criteria
- `ui_layer` is a CanvasLayer holding hud, results_panel and shop_panel.
- HUD visible while aiming/flying and updated during flight; results shown after the run ("New best!" on the first);
  the Continue button opens the shop; shop buttons buy and refresh; Launch! starts the next aim.
