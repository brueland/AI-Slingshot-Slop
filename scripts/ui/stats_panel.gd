class_name StatsPanel
extends PanelContainer
## A panel showing lifetime stats and a chart of recent runs.

signal closed

var runs_label: Label
var distance_label: Label
var best_label: Label
var height_label: Label
var stars_label: Label
var bounces_label: Label
var rogue_label: Label
var daily_label: Label
var hats_label: Label
var combo_label: Label
var chart: DistanceChart
var close_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(420, 0)
	
	var vbox := VBoxContainer.new()
	vbox.name = "VBoxContainer"
	add_child(vbox)
	
	var title_label := Label.new()
	title_label.text = "Stats"
	title_label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title_label)
	
	runs_label = Label.new()
	runs_label.name = "RunsLabel"
	vbox.add_child(runs_label)
	
	distance_label = Label.new()
	distance_label.name = "DistanceLabel"
	vbox.add_child(distance_label)
	
	best_label = Label.new()
	best_label.name = "BestLabel"
	vbox.add_child(best_label)
	
	height_label = Label.new()
	height_label.name = "HeightLabel"
	vbox.add_child(height_label)
	
	stars_label = Label.new()
	stars_label.name = "StarsLabel"
	vbox.add_child(stars_label)
	
	bounces_label = Label.new()
	bounces_label.name = "BouncesLabel"
	vbox.add_child(bounces_label)
	
	rogue_label = Label.new()
	vbox.add_child(rogue_label)
	daily_label = Label.new()
	vbox.add_child(daily_label)
	hats_label = Label.new()
	vbox.add_child(hats_label)
	combo_label = Label.new()
	vbox.add_child(combo_label)
	
	var chart_label := Label.new()
	chart_label.text = "Last 10 runs"
	vbox.add_child(chart_label)
	
	chart = DistanceChart.new()
	chart.name = "Chart"
	vbox.add_child(chart)
	
	close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = "Close"
	vbox.add_child(close_button)
	
	# Connect the close button signal
	close_button.pressed.connect(func(): emit_signal("closed"))
	
	hide()


func show_stats(progress: Progress) -> void:
	runs_label.text = "Runs: %d" % progress.total_runs
	distance_label.text = "Total distance: %d m" % floori(float(progress.lifetime["distance"]))
	best_label.text = "Best distance: %d m" % floori(progress.best_distance)
	height_label.text = "Best height: %d m" % floori(float(progress.lifetime["best_height"]))
	stars_label.text = "Stars collected: %d" % int(progress.lifetime["stars"])
	bounces_label.text = "Bounces: %d" % int(progress.lifetime["bounces"])
	rogue_label.text = "Best roguelike run: %d rounds" % progress.best_rogue_round
	daily_label.text = "Daily runs played: %d" % progress.daily_best.size()
	combo_label.text = "Best combo: x%d" % progress.best_combo
	hats_label.text = "Hats: %d / %d" % [Hats.unlocked(progress).size() - 1, Hats.LIST.size() - 1]
	
	chart.set_values(progress.recent_distances)
	show()
