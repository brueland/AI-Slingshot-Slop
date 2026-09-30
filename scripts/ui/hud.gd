class_name Hud
extends Control
## Flight readouts (top left) and progress (top right). Never blocks the mouse.

const HINT_AIM: String = "Drag the alien back, aim, and let go!"
const HINT_BOOST: String = "Press Space in the air to boost!"
const HINT_REPEAT: String = "Press R to repeat your last shot"

var distance_label: Label
var height_label: Label
var stars_label: Label
var boosts_label: Label
var best_label: Label
var coins_label: Label
var goal_label: Label
var hint_label: Label
var altitude_bar: AltitudeBar
var perks_label: Label
var boss_label: Label
var lucky_label: Label

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
	
	altitude_bar = AltitudeBar.new()
	left_container.add_child(altitude_bar)
	
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
	
	perks_label = Label.new()
	perks_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	perks_label.custom_minimum_size = Vector2(300, 0)
	perks_label.add_theme_font_size_override("font_size", 16)
	perks_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	perks_label.hide()
	right_container.add_child(perks_label)
	
	# Boss banner at the top center
	boss_label = Label.new()
	boss_label.text = "BOSS ROUND!"
	boss_label.add_theme_font_size_override("font_size", 34)
	boss_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.anchor_left = 0.5
	boss_label.anchor_right = 0.5
	boss_label.offset_left = -200
	boss_label.offset_right = 200
	boss_label.offset_top = 16
	boss_label.offset_bottom = 60
	boss_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_label.hide()
	add_child(boss_label)
	lucky_label = Label.new()
	lucky_label.text = "Lucky round! Beat it for a reroll"
	lucky_label.add_theme_font_size_override("font_size", 24)
	lucky_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
	lucky_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lucky_label.anchor_left = 0.5
	lucky_label.anchor_right = 0.5
	lucky_label.offset_left = -240
	lucky_label.offset_right = 240
	lucky_label.offset_top = 64
	lucky_label.offset_bottom = 96
	lucky_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lucky_label.hide()
	add_child(lucky_label)
	
	# Hint label at bottom center
	hint_label = Label.new()
	hint_label.add_theme_font_size_override("font_size", 26)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.anchor_left = 0.5
	hint_label.anchor_right = 0.5
	hint_label.anchor_top = 1.0
	hint_label.anchor_bottom = 1.0
	hint_label.offset_left = -320
	hint_label.offset_right = 320
	hint_label.offset_top = -90
	hint_label.offset_bottom = -50
	hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint_label.hide()
	add_child(hint_label)
	
	# Initialize with default values
	update_flight(0.0, 0.0, 0, 0)
	update_progress(0.0, 0)

func show_hint(text: String) -> void:
	hint_label.text = text
	hint_label.show()

## Roguelike: the perks taken so far, under the goal (hidden when `text` is empty).
func show_perks(text: String) -> void:
	perks_label.text = "Perks: " + text
	perks_label.visible = text != ""


func show_lucky(on: bool) -> void:
	lucky_label.visible = on


func show_boss(on: bool) -> void:
	boss_label.visible = on


func hide_hint() -> void:
	hint_label.hide()

func update_flight(distance: float, height: float, stars: int, boosts: int) -> void:
	distance_label.text = "Distance: %d m" % floori(maxf(distance, 0.0))
	height_label.text = "Height: %d m" % floori(maxf(height, 0.0))
	stars_label.text = "Stars: %d" % stars
	boosts_label.text = "Boosts: %d" % boosts
	altitude_bar.set_height(height)

func update_progress(best: float, coins: int) -> void:
	best_label.text = "Best: %d m" % floori(best)
	coins_label.text = "Coins: %d" % coins
	var next := Milestones.next_milestone(best)
	if next == {}:
		goal_label.text = "All milestones reached!"
	else:
		goal_label.text = "Next: %s at %d m" % [next["name"], int(next["distance"])]


## Roguelike: the right column shows the round, lives and the current goal instead of best/coins/next.
func show_rogue(goal_text: String, round_number: int, lives: int) -> void:
	best_label.text = "Round %d" % round_number
	coins_label.text = "Lives: %d" % lives
	goal_label.text = "Goal: %s" % goal_text
