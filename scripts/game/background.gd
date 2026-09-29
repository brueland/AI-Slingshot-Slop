class_name SkyBackground
extends Node2D
## Parallax sky and clouds behind the world. Parallax2D layers follow the camera on their own.

const SKY_TEXTURE: String = "res://assets/backgrounds/sky.png"
const CLOUD_TEXTURE: String = "res://assets/sprites/cloud.png"
const HIGH_SKY_COLOR := Color(0.45, 0.5, 0.85)
const HIGH_ALTITUDE_M: float = 150.0

var layers: Array[Parallax2D] = []
var stars_layer: Parallax2D
var star_field: StarField

func _ready() -> void:
	z_index = -10
	
	# Sky layer
	var sky_layer = Parallax2D.new()
	sky_layer.scroll_scale = Vector2(0.1, 0.05)
	sky_layer.repeat_size = Vector2(1536, 0)
	sky_layer.repeat_times = 3
	
	var sky_sprite = Sprite2D.new()
	sky_sprite.texture = preload(SKY_TEXTURE)
	sky_sprite.centered = false
	sky_sprite.scale = Vector2(1.5, 1.5)
	sky_sprite.position = Vector2(-768, -1400)
	
	sky_layer.add_child(sky_sprite)
	add_child(sky_layer)
	layers.append(sky_layer)
	
	# Cloud layer
	var cloud_layer = Parallax2D.new()
	cloud_layer.scroll_scale = Vector2(0.3, 0.2)
	cloud_layer.repeat_size = Vector2(1600, 0)
	cloud_layer.repeat_times = 3
	cloud_layer.autoscroll = Vector2(-12, 0)
	
	for i in range(4):
		var cloud_sprite = Sprite2D.new()
		cloud_sprite.texture = preload(CLOUD_TEXTURE)
		cloud_sprite.position = Vector2(i * 400, -420 - (i % 2) * 140)
		cloud_layer.add_child(cloud_sprite)
	
	add_child(cloud_layer)
	layers.append(cloud_layer)
	
	# Night stars: a separate layer (not in `layers`), almost fixed to the screen
	stars_layer = Parallax2D.new()
	stars_layer.scroll_scale = Vector2(0.05, 0.02)
	stars_layer.repeat_size = Vector2(1800, 0)
	stars_layer.repeat_times = 3
	star_field = StarField.new()
	stars_layer.add_child(star_field)
	add_child(stars_layer)

## Tints the whole sky toward deep blue as the projectile climbs (full tint at HIGH_ALTITUDE_M).
func set_altitude(height_m: float) -> void:
	var t := clampf(height_m / HIGH_ALTITUDE_M, 0.0, 1.0)
	modulate = Color.WHITE.lerp(HIGH_SKY_COLOR, t)
	if star_field != null:
		star_field.set_height(height_m)
