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
var pause_menu: PauseMenu
var tip_label: Label
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
	pause_menu = PauseMenu.new()
	add_child(pause_menu)
	tip_label = Label.new()
	tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_label.anchor_left = 0.5
	tip_label.anchor_right = 0.5
	tip_label.anchor_top = 1.0
	tip_label.anchor_bottom = 1.0
	tip_label.offset_left = -420
	tip_label.offset_right = 420
	tip_label.offset_top = -44
	tip_label.offset_bottom = -14
	tip_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.85))
	tip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tip_label)
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
		hud.show_perks(RoguePerks.summary(main.rogue.perks))
		hud.show_boss(str(main.rogue.goal.get("type", "")) == "boss")
	elif hud.visible:
		hud.update_progress(progress.best_distance, progress.coins)
		hud.show_perks("")
		hud.show_boss(false)
	title_panel.visible = state == "TITLE"
	tip_label.visible = title_panel.visible
	tip_label.text = Tips.for_date(Daily.today())
	if title_panel.visible:
		title_panel.show_progress(progress.best_distance, progress.total_runs)
		title_panel.set_mascot_hat(progress.hat)
		title_panel.rogue_best_label.visible = progress.best_rogue_round > 0
		title_panel.rogue_best_label.text = "Roguelike best: %d rounds" % progress.best_rogue_round
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
	var daily_key: String = main.daily_key
	rogue_over_panel.daily_label.visible = daily_key != ""
	rogue_over_panel.daily_label.text = "Daily run %s - best today: %d rounds" % [daily_key, int(progress.daily_best.get(daily_key, 0))]
	rogue_over_panel.show_history(progress.rogue_history)
	var streak := Daily.streak(progress.daily_best, Daily.today())
	rogue_over_panel.streak_label.visible = daily_key != "" and streak > 0
	rogue_over_panel.streak_label.text = "Daily streak: %d day%s" % [streak, "" if streak == 1 else "s"]


func show_rogue_screens(active: bool, run: RogueRun, outcome: Dictionary, best_rounds: int) -> void:
	rogue_panel.hide()
	rogue_over_panel.hide()
	if not active or run == null:
		return
	if run.is_over():
		rogue_over_panel.show_over(run, best_rounds)
	else:
		rogue_panel.show_outcome(outcome, run)


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
	rogue_over_panel.replay_pressed.connect(Callable(main, "replay_rogue_seed"))
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
	options_panel.shake_toggled.connect(Callable(main, "set_shake"))
	options_panel.closed.connect(options_panel.hide)
