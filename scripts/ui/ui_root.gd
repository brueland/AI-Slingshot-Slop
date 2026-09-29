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
	ui_theme = UiTheme.build()
	for child in get_children():
		if child is Control:
			child.theme = ui_theme


func show_rogue_screens(active: bool, run: RogueRun, outcome: Dictionary, best_rounds: int) -> void:
	rogue_panel.hide()
	rogue_over_panel.hide()
	if not active or run == null:
		return
	if run.is_over():
		rogue_over_panel.show_over(run, best_rounds)
	else:
		rogue_panel.show_outcome(outcome, run)
