class_name Effects
extends Node2D
## One-shot particle effects (CPUParticles2D) that free themselves when they finish.

const PUFF_TEXTURE: String = "res://assets/sprites/cloud.png"
const STAR_TEXTURE: String = "res://assets/sprites/star.png"


func spawn_dust(at: Vector2, strength: float) -> CPUParticles2D:
	var p := _make(at, clampi(roundi(strength * 2.0), 6, 24), 0.6)
	p.texture = load(PUFF_TEXTURE)
	p.scale_amount_min = 0.08
	p.scale_amount_max = 0.16
	p.direction = Vector2(0, -1)
	p.spread = 70.0
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 120.0
	p.gravity = Vector2(0, 200)
	p.color = Color(0.55, 0.45, 0.35, 0.8)
	return p


func spawn_sparkle(at: Vector2) -> CPUParticles2D:
	var p := _make(at, 12, 0.5)
	p.texture = load(STAR_TEXTURE)
	p.scale_amount_min = 0.1
	p.scale_amount_max = 0.2
	p.spread = 180.0
	p.initial_velocity_min = 80.0
	p.initial_velocity_max = 160.0
	p.gravity = Vector2.ZERO
	p.color = Color(1.0, 0.9, 0.3)
	return p


func spawn_burst(at: Vector2) -> CPUParticles2D:
	var p := _make(at, 16, 0.5)
	p.texture = load(PUFF_TEXTURE)
	p.scale_amount_min = 0.06
	p.scale_amount_max = 0.12
	p.direction = Vector2(0, -1)
	p.spread = 35.0
	p.initial_velocity_min = 150.0
	p.initial_velocity_max = 260.0
	p.gravity = Vector2(0, 300)
	p.color = Color.WHITE
	return p


func spawn_flame(at: Vector2) -> CPUParticles2D:
	var p := _make(at, 20, 0.4)
	p.texture = load(PUFF_TEXTURE)
	p.scale_amount_min = 0.05
	p.scale_amount_max = 0.1
	p.direction = Vector2(-1, 1).normalized()
	p.spread = 25.0
	p.initial_velocity_min = 120.0
	p.initial_velocity_max = 220.0
	p.gravity = Vector2.ZERO
	p.color = Color(1.0, 0.55, 0.1)
	return p


## Party confetti: many small squares in bright colors that burst up and flutter down.
func spawn_confetti(at: Vector2) -> CPUParticles2D:
	var p := _make(at, 60, 1.1)
	p.direction = Vector2(0, -1)
	p.spread = 70.0
	p.initial_velocity_min = 180.0
	p.initial_velocity_max = 340.0
	p.gravity = Vector2(0, 420)
	p.angular_velocity_min = -360.0
	p.angular_velocity_max = 360.0
	p.scale_amount_min = 3.0
	p.scale_amount_max = 5.0
	var colors := Gradient.new()
	colors.set_color(0, Color(1.0, 0.3, 0.4))
	colors.set_color(1, Color(0.3, 0.6, 1.0))
	colors.add_point(0.33, Color(1.0, 0.85, 0.2))
	colors.add_point(0.66, Color(0.4, 0.9, 0.4))
	p.color_initial_ramp = colors
	return p


func _make(at: Vector2, amount: int, lifetime: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.position = at
	p.one_shot = true
	p.explosiveness = 0.9
	p.amount = amount
	p.lifetime = lifetime
	p.emitting = true
	p.finished.connect(p.queue_free)
	add_child(p)
	return p
