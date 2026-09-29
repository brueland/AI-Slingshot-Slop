class_name GroundShadow
extends Node2D
## A soft oval shadow on the ground under the projectile; it shrinks and fades as the projectile rises.

const RADIUS_PX: float = 14.0

var shadow_scale: float = 1.0


func update_from(world_pos: Vector2) -> void:
	position = WorldView.world_to_screen(Vector2(world_pos.x, 0.0))
	shadow_scale = clampf(1.0 - world_pos.y / 30.0, 0.3, 1.0)
	queue_redraw()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(shadow_scale, shadow_scale * 0.35))
	draw_circle(Vector2.ZERO, RADIUS_PX, Color(0, 0, 0, 0.35 * shadow_scale))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
