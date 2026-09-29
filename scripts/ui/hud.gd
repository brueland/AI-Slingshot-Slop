class_name Hud
extends Control
## Flight readouts (top left) and progress (top right). Never blocks the mouse.

var distance_label: Label
var height_label: Label
var stars_label: Label
var boosts_label: Label
var best_label: Label
var coins_label: Label
var goal_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Left VBoxContainer for flight readouts
	var left_container := VBoxContainer.new()
	left_container.position = Vector2(16, 16)
	add_child(left_container)
	left_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	distance_label = Label.new()
	left_container.add_child(distance_label)
	distance_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	distance_label.add_theme_font_size_override("font_size", 22)
	
	height_label = Label.new()
	left_container.add_child(height_label)
	height_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	height_label.add_theme_font_size_override("font_size", 22)
	
	stars_label = Label.new()
	left_container.add_child(stars_label)
	stars_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stars_label.add_theme_font_size_override("font_size", 22)
	
	boosts_label = Label.new()
	left_container.add_child(boosts_label)
	boosts_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boosts_label.add_theme_font_size_override("font_size", 22)
	
	# Right VBoxContainer for progress
	var right_container := VBoxContainer.new()
	right_container.anchor_left = 1.0
	right_container.anchor_right = 1.0
	right_container.offset_left = -320
	right_container.offset_right = -16
	right_container.offset_top = 16
	add_child(right_container)
	right_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	best_label = Label.new()
	right_container.add_child(best_label)
	best_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	best_label.add_theme_font_size_override("font_size", 22)
	
	coins_label = Label.new()
	right_container.add_child(coins_label)
	coins_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coins_label.add_theme_font_size_override("font_size", 22)
	
	goal_label = Label.new()
	right_container.add_child(goal_label)
	goal_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	goal_label.add_theme_font_size_override("font_size", 22)
	
	# Initialize with default values
	update_flight(0.0, 0.0, 0, 0)
	update_progress(0.0, 0)

func update_flight(distance: float, height: float, stars: int, boosts: int) -> void:
	distance_label.text = "Distance: %d m" % floori(maxf(distance, 0.0))
	height_label.text = "Height: %d m" % floori(maxf(height, 0.0))
	stars_label.text = "Stars: %d" % stars
	boosts_label.text = "Boosts: %d" % boosts

func update_progress(best: float, coins: int) -> void:
	best_label.text = "Best: %d m" % floori(best)
	coins_label.text = "Coins: %d" % coins
	var next := Milestones.next_milestone(best)
	if next == {}:
		goal_label.text = "All milestones reached!"
	else:
		goal_label.text = "Next: %s at %d m" % [next["name"], int(next["distance"])]
