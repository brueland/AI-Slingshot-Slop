class_name SkyBackground
extends Node2D
## Parallax sky and clouds behind the world. Parallax2D layers follow the camera on their own.

const CLOUD_TEXTURE: String = "res://assets/sprites/cloud.png"
## The clouds fade out while the alien climbs from CLOUDS_FADE_START_M to CLOUDS_GONE_M.
const CLOUDS_FADE_START_M: float = 60.0
const CLOUDS_GONE_M: float = 120.0

var layers: Array[Parallax2D] = []
var stars_layer: Parallax2D
var star_field: StarField
var hills_layer: Parallax2D
var hills: Hills
var sky_gradient: SkyGradient

func _ready() -> void:
	z_index = -10
	
	# Sky layer
	var sky_layer = Parallax2D.new()
	sky_layer.scroll_scale = Vector2(0.1, 0.05)
	sky_layer.repeat_size = Vector2(1536, 0)
	sky_layer.repeat_times = 3
	
	# The sky itself: a gradient drawn behind everything in screen space (a CanvasLayer ignores the parallax)
	sky_gradient = SkyGradient.new()
	sky_layer.add_child(sky_gradient)
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
	
	# Hills: a separate layer (not in `layers`) that scrolls slower than the world
	hills_layer = Parallax2D.new()
	hills_layer.scroll_scale = Vector2(0.3, 1.0)
	hills_layer.repeat_size = Vector2(Hills.WIDTH, 0)
	hills_layer.repeat_times = 3
	hills = Hills.new()
	hills_layer.add_child(hills)
	add_child(hills_layer)

## As the projectile climbs, the sky darkens toward space (SkyGradient) and the clouds fade out.
func set_altitude(height_m: float) -> void:
	sky_gradient.set_height(height_m)
	layers[1].modulate.a = 1.0 - clampf((height_m - CLOUDS_FADE_START_M) / (CLOUDS_GONE_M - CLOUDS_FADE_START_M), 0.0, 1.0)
	if star_field != null:
		star_field.set_height(height_m)
