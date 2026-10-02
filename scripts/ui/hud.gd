class_name Hud
extends Control
## Flight readouts (top left) and progress (top right). Never blocks the mouse.

signal menu_pressed

const HINT_AIM: String = "Drag the alien back, aim, and let go!"
const HINT_BOOST: String = "Hold Space in the air to fire the rocket!"
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
var perk_chips: PerkChips
var boss_label: Label
var lucky_label: Label
var weather_label: Label
var goal_progress_label: Label
var course_bar: CourseBar
var menu_button: Button
var speed_label: Label
var goal_bar: ProgressBar
var rocket_bar: RocketGauge
## The next milestone's distance (0 when every milestone is reached).
var next_target: float = 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Left VBoxContainer for flight readouts
	var left_panel := PanelContainer.new()
	left_panel.position = Vector2(12, 12)
	left_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_panel.add_theme_stylebox_override("panel", UiTheme.hud_panel())
	add_child(left_panel)
	var left_row := HBoxContainer.new()
	left_row.add_theme_constant_override("separation", 14)
	left_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_panel.add_child(left_row)
	var left_container := VBoxContainer.new()
	left_row.add_child(left_container)
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
	rocket_bar = RocketGauge.new()
	left_container.add_child(rocket_bar)
	
	speed_label = Label.new()
	left_container.add_child(speed_label)
	speed_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	speed_label.add_theme_font_size_override("font_size", 22)
	
	altitude_bar = AltitudeBar.new()
	left_row.add_child(altitude_bar)
	
	# Right VBoxContainer for progress
	var right_panel := PanelContainer.new()
	right_panel.anchor_left = 1.0
	right_panel.anchor_right = 1.0
	right_panel.offset_left = -344
	right_panel.offset_right = -12
	right_panel.offset_top = 12
	right_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_panel.add_theme_stylebox_override("panel", UiTheme.hud_panel())
	add_child(right_panel)
	var right_container := VBoxContainer.new()
	right_panel.add_child(right_container)
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
	goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goal_label.custom_minimum_size = Vector2(300, 0)
	
	goal_progress_label = Label.new()
	goal_progress_label.add_theme_font_size_override("font_size", 20)
	goal_progress_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goal_progress_label.custom_minimum_size = Vector2(300, 0)
	goal_progress_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	goal_progress_label.hide()
	right_container.add_child(goal_progress_label)
	
	goal_bar = ProgressBar.new()
	goal_bar.custom_minimum_size = Vector2(0, 12)
	goal_bar.max_value = 1.0
	goal_bar.step = 0.0
	goal_bar.show_percentage = false
	goal_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_container.add_child(goal_bar)
	
	perk_chips = PerkChips.new()
	right_container.add_child(perk_chips)
	
	weather_label = Label.new()
	weather_label.add_theme_font_size_override("font_size", 18)
	weather_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	weather_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	weather_label.hide()
	right_container.add_child(weather_label)
	
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
	
	# Course bar at the very bottom
	course_bar = CourseBar.new()
	course_bar.anchor_left = 0.5
	course_bar.anchor_right = 0.5
	course_bar.anchor_top = 1.0
	course_bar.anchor_bottom = 1.0
	course_bar.offset_left = -200
	course_bar.offset_right = 200
	course_bar.offset_top = -30
	course_bar.offset_bottom = -22
	add_child(course_bar)
	
	# Menu button in the bottom-right corner: pauses the game (the pause menu has Options and Quit to title)
	menu_button = Button.new()
	menu_button.text = "Menu (Esc)"
	menu_button.focus_mode = Control.FOCUS_NONE
	menu_button.anchor_left = 1.0
	menu_button.anchor_right = 1.0
	menu_button.anchor_top = 1.0
	menu_button.anchor_bottom = 1.0
	menu_button.offset_left = -156
	menu_button.offset_right = -16
	menu_button.offset_top = -56
	menu_button.offset_bottom = -16
	menu_button.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	menu_button.grow_vertical = Control.GROW_DIRECTION_BEGIN
	menu_button.pressed.connect(func(): menu_pressed.emit())
	add_child(menu_button)
	
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
	show_speed(0.0)
	update_progress(0.0, 0)

func show_hint(text: String) -> void:
	hint_label.text = text
	hint_label.show()

## Roguelike: the perks taken so far as boxes with counts, under the goal, then the run's stars and star boosts.
func show_perks(perk_ids: Array, stars: int = 0, boosts: Dictionary = {}) -> void:
	perk_chips.show_perks(perk_ids, stars, boosts)


## Roguelike: the round's weather under the perks (hidden when `weather_name` is empty).
func show_weather(weather_name: String) -> void:
	weather_label.text = "Weather: " + weather_name
	weather_label.visible = weather_name != ""


func show_lucky(on: bool) -> void:
	lucky_label.visible = on


func show_boss(on: bool) -> void:
	boss_label.visible = on


func hide_hint() -> void:
	hint_label.hide()

## `rocket`: seconds of rocket left; `rocket_max`: a full tank (0 = no rocket).
func update_flight(distance: float, height: float, stars: int, rocket: float, rocket_max: float = 0.0) -> void:
	distance_label.text = "Distance: %d m" % floori(maxf(distance, 0.0))
	height_label.text = "Height: %d m" % floori(maxf(height, 0.0))
	stars_label.text = "Stars: %d" % stars
	boosts_label.text = "Rocket: none" if rocket_max <= 0.0 and rocket <= 0.0 else "Rocket: %.1f s" % maxf(rocket, 0.0)
	rocket_bar.show_fuel(rocket, rocket_max)
	altitude_bar.set_height(height)
	course_bar.set_distance(distance)
	if next_target > 0.0:
		goal_bar.value = clampf(distance / next_target, 0.0, 1.0)

func update_progress(best: float, coins: int) -> void:
	best_label.text = "Best: %d m" % floori(best)
	coins_label.text = "Coins: %d" % coins
	course_bar.set_best(best)
	var next := Milestones.next_milestone(best)
	if next == {}:
		goal_label.text = "All milestones reached!"
		next_target = 0.0
	else:
		goal_label.text = "Next: %s at %d m" % [next["name"], int(next["distance"])]
		next_target = float(next["distance"])
	goal_bar.value = 1.0 if next_target <= 0.0 else clampf(best / next_target, 0.0, 1.0)


func show_speed(meters_per_second: float) -> void:
	speed_label.text = "Speed: %d m/s" % roundi(meters_per_second)


## Roguelike: the live goal readout under the goal ("" hides it); green once the goal is met.
func show_goal_progress(text: String, met: bool, ratio: float = -1.0) -> void:
	if ratio >= 0.0:
		goal_bar.value = ratio
	goal_progress_label.text = text
	goal_progress_label.visible = text != ""
	goal_progress_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5) if met else Color.WHITE)


## Roguelike: the right column shows the round, lives and the current goal instead of best/coins/next.
func show_rogue(goal_text: String, round_number: int, lives: int) -> void:
	best_label.text = "Round %d" % round_number
	coins_label.text = "Lives: %d" % lives
	goal_label.text = "Goal: %s" % goal_text
	goal_bar.value = 0.0
