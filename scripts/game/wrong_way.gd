class_name WrongWay
extends Node2D
## Behind the slingshot: red "WRONG WAY" signs pointing back to the course and, at Balance.WALL_X, a giant brick wall
## the alien bounces off (FlightSim does the bouncing). Behind the wall, for whoever breaks through it, a big sign
## thanks the players.

const SIGNS_M: Array[float] = [-25.0, -55.0, -85.0]
const WALL_HEIGHT_M: float = 60.0
const WALL_THICK_M: float = 4.0
const BRICK := Color(0.72, 0.3, 0.22)
const MORTAR := Color(0.86, 0.8, 0.72)
## Where the thank-you sign stands (meters), between the wall and the end of the world.
const SECRET_SIGN_M: float = -190.0

var shot: RunSession
## The wall is down in this shot (the alien broke through).
var wall_down: bool = false


func watch(session: RunSession) -> void:
	shot = session
	wall_down = false
	session.sim.wall_broken.connect(_on_wall_broken)
	queue_redraw()


func _on_wall_broken() -> void:
	wall_down = true
	queue_redraw()
	var popup := FloatingText.new()
	popup.setup("You found the secret!", Color(1.0, 0.85, 0.3))
	popup.position = WorldView.world_to_screen(Vector2(Balance.WALL_X - 5.0, 8.0))
	add_child(popup)


## Behind the wall: the thank-you sign and the end of the world.
func _draw_secret() -> void:
	var base := WorldView.ground_point(SECRET_SIGN_M)
	var font := UiTheme.game_font(800)
	for post in [-150.0, 140.0]:
		draw_rect(Rect2(base + Vector2(post, -120), Vector2(10, 120)), Color(0.45, 0.3, 0.18))
	draw_rect(Rect2(base + Vector2(-190, -330), Vector2(380, 220)), Color(1.0, 0.85, 0.3))
	draw_rect(Rect2(base + Vector2(-182, -322), Vector2(364, 204)), Color(0.18, 0.12, 0.35))
	draw_string(font, base + Vector2(-182, -262), "THANK YOU", HORIZONTAL_ALIGNMENT_CENTER, 364, 44, Color(1.0, 0.85, 0.3))
	draw_string(font, base + Vector2(-182, -214), "FOR PLAYING!", HORIZONTAL_ALIGNMENT_CENTER, 364, 36, Color.WHITE)
	draw_string(font, base + Vector2(-182, -176), "You broke through to the secret.", HORIZONTAL_ALIGNMENT_CENTER, 364, 18, Color(0.85, 0.85, 1.0))
	draw_string(font, base + Vector2(-182, -150), "Have a wonderful flight!", HORIZONTAL_ALIGNMENT_CENTER, 364, 18, Color(0.85, 0.85, 1.0))
	for side in [-1.0, 1.0]:
		_draw_heart(base + Vector2(side * 150.0, -284.0), Color(1.0, 0.4, 0.55))
	var end := WorldView.world_to_screen(Vector2(Balance.SECRET_END_X, 0.0))
	draw_rect(Rect2(end.x - 64.0, end.y - 960.0, 64.0, 968.0), Color(0.45, 0.45, 0.5))


func _draw_heart(at: Vector2, color: Color) -> void:
	draw_circle(at + Vector2(-7, 0), 8.0, color)
	draw_circle(at + Vector2(7, 0), 8.0, color)
	draw_colored_polygon(PackedVector2Array([at + Vector2(-14.5, 3), at + Vector2(14.5, 3), at + Vector2(0, 18)]), color)


## Where the wall stood after the alien broke through: a pile of bricks.
func _draw_rubble() -> void:
	var right := WorldView.world_to_screen(Vector2(Balance.WALL_X, 0.0))
	for k in 14:
		var x := right.x - 70.0 + float((k * 37) % 120)
		var y := right.y - 6.0 - float((k * 13) % 30)
		draw_rect(Rect2(x, y, 30, 13), BRICK if k % 3 != 0 else MORTAR)


func _draw() -> void:
	var font := UiTheme.game_font(800)
	for x in SIGNS_M:
		var base := WorldView.ground_point(x)
		draw_rect(Rect2(base + Vector2(-3, -70), Vector2(6, 70)), Color(0.45, 0.3, 0.18))
		draw_rect(Rect2(base + Vector2(-68, -108), Vector2(136, 40)), Color.WHITE)
		draw_rect(Rect2(base + Vector2(-65, -105), Vector2(130, 34)), Color(0.85, 0.15, 0.12))
		draw_string(font, base + Vector2(-56, -81), "WRONG WAY", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
		draw_colored_polygon(PackedVector2Array([base + Vector2(70, -98), base + Vector2(90, -88), base + Vector2(70, -78)]), Color(0.85, 0.15, 0.12))
	_draw_secret()
	if wall_down:
		_draw_rubble()
		return
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
