class_name VictoryPanel
extends PanelContainer
## Shown once, the first time a run reaches GOAL_DISTANCE.

signal continue_pressed

var message_label: Label
var continue_button: Button
var confetti: CPUParticles2D

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(480, 0)
	
	var vbox := VBoxContainer.new()
	add_child(vbox)
	
	message_label = Label.new()
	message_label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(message_label)
	
	continue_button = Button.new()
	continue_button.text = "Keep flying"
	continue_button.connect("pressed", Callable(self, "_on_continue_pressed"))
	vbox.add_child(continue_button)
	
	confetti = CPUParticles2D.new()
	confetti.amount = 80
	confetti.lifetime = 2.5
	confetti.emitting = false
	confetti.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	confetti.emission_rect_extents = Vector2(240, 4)
	confetti.position = Vector2(240, -20)
	confetti.direction = Vector2(0, 1)
	confetti.gravity = Vector2(0, 160)
	confetti.initial_velocity_min = 20.0
	confetti.initial_velocity_max = 80.0
	confetti.scale_amount_min = 3.0
	confetti.scale_amount_max = 5.0
	var colors := Gradient.new()
	colors.set_color(0, Color(1.0, 0.3, 0.4))
	colors.set_color(1, Color(0.3, 0.6, 1.0))
	colors.add_point(0.5, Color(1.0, 0.85, 0.2))
	confetti.color_initial_ramp = colors
	add_child(confetti)
	
	hide()

func _on_continue_pressed():
	emit_signal("continue_pressed")

func show_victory(runs: int) -> void:
	message_label.text = "You reached %d m in %d runs!" % [int(Balance.GOAL_DISTANCE), runs]
	confetti.emitting = true
	show()
