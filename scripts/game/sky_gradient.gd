class_name SkyGradient
extends CanvasLayer
## The sky behind everything: a vertical gradient over the whole screen that goes from day blue near the ground
## through deep blue to black space high up (fully dark from 180 m), where the stars come out.

const HEIGHTS: Array[float] = [0.0, 40.0, 100.0, 180.0]
const TOPS: Array[Color] = [Color(0.36, 0.62, 0.93), Color(0.2, 0.4, 0.8), Color(0.05, 0.1, 0.35), Color(0.0, 0.0, 0.05)]
const BOTTOMS: Array[Color] = [Color(0.72, 0.88, 1.0), Color(0.55, 0.75, 0.97), Color(0.25, 0.45, 0.85), Color(0.06, 0.12, 0.35)]

var height: float = 0.0
var canvas: Node2D


func _ready() -> void:
	layer = -100
	canvas = Node2D.new()
	add_child(canvas)
	canvas.draw.connect(_draw_sky)


## The [top, bottom] colors of the sky at `height_m`, blended between the HEIGHTS.
static func colors_for_height(height_m: float) -> Array[Color]:
	var i := 1
	while i < HEIGHTS.size() - 1 and height_m > HEIGHTS[i]:
		i += 1
	var t := clampf((height_m - HEIGHTS[i - 1]) / (HEIGHTS[i] - HEIGHTS[i - 1]), 0.0, 1.0)
	var out: Array[Color] = [TOPS[i - 1].lerp(TOPS[i], t), BOTTOMS[i - 1].lerp(BOTTOMS[i], t)]
	return out


func set_height(height_m: float) -> void:
	height = height_m
	if canvas != null:
		canvas.queue_redraw()


func _draw_sky() -> void:
	var size := canvas.get_viewport_rect().size
	var c := colors_for_height(height)
	canvas.draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0.0), size, Vector2(0.0, size.y)]),
		PackedColorArray([c[0], c[0], c[1], c[1]]))
