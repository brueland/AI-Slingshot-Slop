class_name Fader
extends CanvasLayer
## A black screen that fades out after each screen change, so switches feel smooth. Never blocks input.

const DEFAULT_DURATION: float = 0.3

var rect: ColorRect
var duration: float = DEFAULT_DURATION
var time_left: float = 0.0


func _ready() -> void:
	layer = 10
	rect = ColorRect.new()
	rect.color = Color(0, 0, 0, 0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(rect)


func _process(delta: float) -> void:
	advance(delta)


func flash(fade_time: float = DEFAULT_DURATION) -> void:
	duration = maxf(fade_time, 0.01)
	time_left = duration
	rect.color.a = 1.0


func advance(delta: float) -> void:
	if time_left <= 0.0:
		return
	time_left = maxf(0.0, time_left - delta)
	rect.color.a = time_left / duration


func alpha() -> float:
	return rect.color.a
