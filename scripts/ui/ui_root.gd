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
var stats_panel: StatsPanel
var toast: Toast
var wardrobe_panel: WardrobePanel
var rogue_panel: RoguePanel
var rogue_over_panel: RogueOverPanel


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
	stats_panel = StatsPanel.new()
	add_child(stats_panel)
	toast = Toast.new()
	add_child(toast)
	rogue_panel = RoguePanel.new()
	add_child(rogue_panel)
	rogue_over_panel = RogueOverPanel.new()
	add_child(rogue_over_panel)
	wardrobe_panel = WardrobePanel.new()
	add_child(wardrobe_panel)
	ui_theme = UiTheme.build()
	for child in get_children():
		if child is Control:
			child.theme = ui_theme


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


func show_rogue_screens(active: bool, run: RogueRun, outcome: Dictionary, best_rounds: int) -> void:
	rogue_panel.hide()
	rogue_over_panel.hide()
	if not active or run == null:
		return
	if run.is_over():
		rogue_over_panel.show_over(run, best_rounds)
	else:
		rogue_panel.show_outcome(outcome, run)
