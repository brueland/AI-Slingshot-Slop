---
id: 242-boss-view
status: ready
tests: [tests/acceptance/test_242_boss_view.gd]
files: [scripts/game/boss_view.gd, scripts/game/world_builder.gd, scripts/game/feedback.gd]
---

# The boss on the field

Boss fights (tasks 238-241) need to be seen. `BossView` (a new script, drawn in world space behind the alien) draws
the Grumblor: a big one-eyed purple ball with its hands out and a crown floating over its head, red-and-white
targets on and around it (grey once hit this shot), and its HP bar with the shots left. WorldBuilder creates it and
gives it to Feedback, which shows the boss of every new shot (none outside fights) and reacts to hits.

**1. Create the file `scripts/game/boss_view.gd`** with exactly this code (use that exact path as the edit's file name):
```gdscript
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
```

**2. `scripts/game/world_builder.gd`**: exactly these 2 SEARCH/REPLACE edit(s). Each REPLACE keeps the SEARCH lines and adds the new ones; nothing else in the file changes.

Edit 1 - SEARCH:
```gdscript
	main.zone_marker = ZoneMarker.new()
	main.add_child(main.zone_marker)
```
REPLACE:
```gdscript
	main.zone_marker = ZoneMarker.new()
	main.add_child(main.zone_marker)
	var boss_view := BossView.new()
	main.add_child(boss_view)
```

Edit 2 - SEARCH:
```gdscript
	main.feedback = Feedback.new()
	main.add_child(main.feedback)
```
REPLACE:
```gdscript
	main.feedback = Feedback.new()
	main.add_child(main.feedback)
	main.feedback.boss_view = boss_view
```

**3. `scripts/game/feedback.gd`**: exactly these 3 SEARCH/REPLACE edit(s). Edit 2 adds four lines at the end of `watch()`; edit 3 adds `_on_boss_hit()` at the end of the file. Nothing else changes.

Edit 1 - SEARCH:
```gdscript
var cows: Cows
```
REPLACE:
```gdscript
var cows: Cows
var boss_view: BossView
```

Edit 2 - SEARCH:
```gdscript
	if session.balloons != null:
		session.balloons.popped.connect(_on_balloon_popped)
```
REPLACE:
```gdscript
	if session.balloons != null:
		session.balloons.popped.connect(_on_balloon_popped)
	if boss_view != null:
		boss_view.show_fight(session.boss)
	if session.boss != null:
		session.boss.target_hit.connect(_on_boss_hit)
```

Edit 3 - SEARCH:
```gdscript
		effects.spawn_flame(projectile_view.position)
		flame_left = FLAME_EVERY
```
REPLACE:
```gdscript
		effects.spawn_flame(projectile_view.position)
		flame_left = FLAME_EVERY


## The alien hit one of the boss's targets: a "-3!" popup, a burst, a shake and a flash on the boss.
func _on_boss_hit(index: int, damage: int) -> void:
	_say("-%d!" % damage, Color(1.0, 0.35, 0.3))
	if boss_view != null:
		boss_view.flash(index)
	if effects != null and projectile_view != null:
		effects.spawn_burst(projectile_view.position)
	if camera != null:
		camera.shake(5.0, 0.2)
	if audio != null:
		audio.play_sfx("spring")
	add_combo()
```

## Acceptance criteria
- WorldBuilder adds a `BossView` right after the zone marker and sets `main.feedback.boss_view`.
- `Feedback.watch(session)` calls `boss_view.show_fight(session.boss)` and connects `session.boss.target_hit` to `_on_boss_hit`
  (popup "-N!", flash, burst, shake, sound, combo).
