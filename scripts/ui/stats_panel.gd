class_name StatsPanel
extends PanelContainer
## A panel showing lifetime stats and a chart of recent runs.

signal closed

@onready var runs_label: Label = $VBoxContainer/RunsLabel
@onready var distance_label: Label = $VBoxContainer/DistanceLabel
@onready var best_label: Label = $VBoxContainer/BestLabel
@onready var height_label: Label = $VBoxContainer/HeightLabel
@onready var stars_label: Label = $VBoxContainer/StarsLabel
@onready var bounces_label: Label = $VBoxContainer/BouncesLabel
@onready var chart: DistanceChart = $VBoxContainer/Chart
@onready var close_button: Button = $VBoxContainer/CloseButton


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
	
	vbox.add_child(runs_label)
	vbox.add_child(distance_label)
	vbox.add_child(best_label)
	vbox.add_child(height_label)
	vbox.add_child(stars_label)
	vbox.add_child(bounces_label)
	
	var chart_label := Label.new()
	chart_label.text = "Last 10 runs"
	vbox.add_child(chart_label)
	
	vbox.add_child(chart)
	
	vbox.add_child(close_button)
	
	hide()


func show_stats(progress: Progress) -> void:
	runs_label.text = "Runs: %d" % progress.total_runs
	distance_label.text = "Total distance: %d m" % floori(float(progress.lifetime["distance"]))
	best_label.text = "Best distance: %d m" % floori(progress.best_distance)
	height_label.text = "Best height: %d m" % floori(float(progress.lifetime["best_height"]))
	stars_label.text = "Stars collected: %d" % int(progress.lifetime["stars"])
	bounces_label.text = "Bounces: %d" % int(progress.lifetime["bounces"])
	
	chart.set_values(progress.recent_distances)
	show()
