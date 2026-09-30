class_name HelpPanel
extends PanelContainer
## How to play: the controls and what each mode is about.

signal closed

const LINES: Array[String] = [
	"Drag the alien back, aim, and let go to launch it.",
	"Or use the arrow keys: Up/Down for the angle, Left/Right for the power, Enter to launch.",
	"Press Space in the air to use a boost.",
	"Press R to repeat your last shot. Press Esc to pause.",
	"Classic: fly as far as you can, earn coins and buy upgrades. Reach 1000 m to win!",
	"Roguelike: meet a new goal every round and pick a perk after each shot. Three misses and the run is over.",
]

var text_label: Label
var close_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(600, 0)
	var box := VBoxContainer.new()
	add_child(box)
	var title_label := Label.new()
	title_label.text = "How to play"
	title_label.add_theme_font_size_override("font_size", 32)
	box.add_child(title_label)
	text_label = Label.new()
	text_label.text = help_text()
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.custom_minimum_size = Vector2(560, 0)
	box.add_child(text_label)
	close_button = Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(func(): closed.emit())
	box.add_child(close_button)
	hide()


## All of LINES, one per line.
static func help_text() -> String:
	var text := ""
	for line in LINES:
		text += line + "\n"
	return text.strip_edges()
