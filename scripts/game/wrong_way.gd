class_name WrongWay
extends Node2D
## Behind the slingshot: red "WRONG WAY" signs pointing back to the course and, at Balance.WALL_X, a giant brick wall
## the alien bounces off (FlightSim does the bouncing).

const SIGNS_M: Array[float] = [-25.0, -55.0, -85.0]
const WALL_HEIGHT_M: float = 60.0
const WALL_THICK_M: float = 4.0
const BRICK := Color(0.72, 0.3, 0.22)
const MORTAR := Color(0.86, 0.8, 0.72)


func _draw() -> void:
	var font := UiTheme.game_font(800)
	for x in SIGNS_M:
		var base := WorldView.ground_point(x)
		draw_rect(Rect2(base + Vector2(-3, -70), Vector2(6, 70)), Color(0.45, 0.3, 0.18))
		draw_rect(Rect2(base + Vector2(-68, -108), Vector2(136, 40)), Color.WHITE)
		draw_rect(Rect2(base + Vector2(-65, -105), Vector2(130, 34)), Color(0.85, 0.15, 0.12))
		draw_string(font, base + Vector2(-56, -81), "WRONG WAY", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
		draw_colored_polygon(PackedVector2Array([base + Vector2(70, -98), base + Vector2(90, -88), base + Vector2(70, -78)]), Color(0.85, 0.15, 0.12))
	var right := WorldView.world_to_screen(Vector2(Balance.WALL_X, 0.0))
	var w := WALL_THICK_M * Balance.PIXELS_PER_METER
	var h := WALL_HEIGHT_M * Balance.PIXELS_PER_METER
	var left := right.x - w
	draw_rect(Rect2(left, right.y - h, w, h + 8), MORTAR)
	var row := 0
	var y := right.y + 8
	while y > right.y - h:
		var x := left - (16.0 if row % 2 == 1 else 0.0)
		while x < right.x:
			var a := maxf(x, left) + 1.0
			var b := minf(x + 32.0, right.x) - 1.0
			if b > a:
				draw_rect(Rect2(a, y - 15, b - a, 14), BRICK)
			x += 32.0
		y -= 16.0
		row += 1
