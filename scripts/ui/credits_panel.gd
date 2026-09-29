class_name CreditsPanel
extends PanelContainer
## Asset credits (required by the ElvGames music license). Text comes from res://CREDITS.md.

signal closed

const CREDITS_PATH: String = "res://CREDITS.md"
const FALLBACK: String = "Music by ElvGames. Art and sound effects by Kenney (www.kenney.nl)."

var text_label: Label
var close_button: Button


static func credits_text() -> String:
	if FileAccess.file_exists(CREDITS_PATH):
		return FileAccess.get_file_as_string(CREDITS_PATH)
	return FALLBACK


func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(640, 0)
	
	var box: VBoxContainer = VBoxContainer.new()
	add_child(box)
	
	var title_label: Label = Label.new()
	title_label.text = "Credits"
	title_label.add_theme_font_size_override("font_size", 32)
	box.add_child(title_label)
	
	# The credits are longer than the screen is tall: scroll them.
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(600, 420)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	text_label = Label.new()
	text_label.text = credits_text()
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.custom_minimum_size = Vector2(580, 0)
	scroll.add_child(text_label)
	
	close_button = Button.new()
	close_button.text = "Close"
	close_button.connect("pressed", Callable(self, "_on_close_pressed"))
	box.add_child(close_button)
	
	hide()


func _on_close_pressed():
	emit_signal("closed")
