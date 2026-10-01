class_name BossView
extends Node2D
## Draws the roguelike boss, the Grumblor: a big one-eyed purple ball standing on the field with its hands out and a
## crown floating over its head, red-and-white targets on and around it, and its HP bar. Hidden without a fight.

const BODY := Color(0.56, 0.36, 0.78)
const BELLY := Color(0.74, 0.58, 0.92)
const DARK := Color(0.22, 0.1, 0.32)
const GOLD := Color(1.0, 0.8, 0.2)
const RING := Color(0.95, 0.22, 0.2)
const SPENT := Color(0.55, 0.55, 0.55, 0.6)

var boss: BossFight = null
## Seconds the boss still flashes after a hit.
var flash_left: float = 0.0
var bob: float = 0.0


## Shows the boss of `fight` (null hides the view).
func show_fight(fight: BossFight) -> void:
	boss = fight
	visible = fight != null
	flash_left = 0.0
	queue_redraw()


func target_screen(index: int) -> Vector2:
	return WorldView.world_to_screen(boss.target_position(index))


## The alien hit a target: the boss flashes for a moment.
func flash(_index: int) -> void:
	flash_left = 0.3
	queue_redraw()


func _process(delta: float) -> void:
	if boss == null:
		return
	bob = fmod(bob + delta * 2.5, TAU)
	flash_left = maxf(flash_left - delta, 0.0)
	queue_redraw()


func _draw() -> void:
	if boss == null:
		return
	var feet := WorldView.world_to_screen(Vector2(boss.x, 0.0))
	var center := WorldView.world_to_screen(Vector2(boss.x, BossFight.BODY_RADIUS))
	var r := BossFight.BODY_RADIUS * Balance.PIXELS_PER_METER
	var skin := BODY.lerp(Color.WHITE, 0.7) if flash_left > 0.0 else BODY
	draw_set_transform(feet, 0.0, Vector2(1.0, 0.22))
	draw_circle(Vector2.ZERO, r * 1.2, Color(0.0, 0.0, 0.0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for side: float in [-1.0, 1.0]:
		var hand := target_screen(3 if side < 0.0 else 4) + Vector2(0.0, sin(bob + side) * 4.0)
		draw_line(center + Vector2(side * r * 0.7, -r * 0.1), hand, DARK, 12.0)
		draw_circle(hand, 18.0, DARK)
		draw_circle(hand, 14.0, skin)
		draw_circle(feet + Vector2(side * r * 0.45, -8.0), 18.0, DARK)
	draw_circle(center, r + 5.0, DARK)
	draw_circle(center, r, skin)
	draw_circle(target_screen(2), r * 0.42, BELLY)
	var eye := target_screen(1)
	draw_circle(eye, 21.0, DARK)
	draw_circle(eye, 18.0, Color.WHITE)
	draw_circle(eye + Vector2(-6.0, 3.0), 8.0, DARK)
	draw_line(eye + Vector2(-26.0, -30.0), eye + Vector2(24.0, -18.0), DARK, 7.0)
	var mouth := WorldView.world_to_screen(Vector2(boss.x - 0.6, 3.9))
	draw_polyline(PackedVector2Array([mouth + Vector2(-24.0, 0.0), mouth + Vector2(-12.0, 7.0), mouth + Vector2(0.0, 0.0),
		mouth + Vector2(12.0, 7.0), mouth + Vector2(24.0, 0.0)]), DARK, 5.0)
	var crown := target_screen(0) + Vector2(0.0, sin(bob) * 5.0)
	draw_colored_polygon(PackedVector2Array([crown + Vector2(-20.0, 12.0), crown + Vector2(-20.0, -8.0), crown + Vector2(-10.0, 2.0),
		crown + Vector2(0.0, -14.0), crown + Vector2(10.0, 2.0), crown + Vector2(20.0, -8.0), crown + Vector2(20.0, 12.0)]), GOLD)
	for i in BossFight.TARGETS.size():
		var c := crown if i == 0 else target_screen(i)
		var ring := float(BossFight.TARGETS[i]["radius"]) * Balance.PIXELS_PER_METER
		var color := SPENT if boss.hit[i] else RING
		draw_arc(c, ring, 0.0, TAU, 32, color, 4.0)
		draw_arc(c, ring * 0.55, 0.0, TAU, 24, SPENT if boss.hit[i] else Color.WHITE, 3.0)
		draw_circle(c, 3.0, color)
	_draw_hp(WorldView.world_to_screen(Vector2(boss.x, 13.8)))


## Over the crown: the shots left, the boss's name and HP, and the HP bar (red for the HP left).
func _draw_hp(at: Vector2) -> void:
	var font := UiTheme.game_font(700)
	var w := 180.0
	draw_rect(Rect2(at + Vector2(-w / 2.0 - 3.0, -3.0), Vector2(w + 6.0, 20.0)), DARK)
	draw_rect(Rect2(at + Vector2(-w / 2.0, 0.0), Vector2(w * boss.hp / boss.max_hp, 14.0)), RING)
	var title := "GRUMBLOR  %d/%d HP" % [boss.hp, boss.max_hp]
	draw_string_outline(font, at + Vector2(-w / 2.0, -10.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, 6, DARK)
	draw_string(font, at + Vector2(-w / 2.0, -10.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	var shots := "%d shot%s left" % [boss.shots_left, "" if boss.shots_left == 1 else "s"]
	draw_string_outline(font, at + Vector2(-w / 2.0, -34.0), shots, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, 6, DARK)
	draw_string(font, at + Vector2(-w / 2.0, -34.0), shots, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, GOLD)
