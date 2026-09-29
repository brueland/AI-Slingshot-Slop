class_name SkyBackground
extends Node2D
## Parallax sky and clouds behind the world. Parallax2D layers follow the camera on their own.

const SKY_TEXTURE: String = "res://assets/backgrounds/sky.png"
const CLOUD_TEXTURE: String = "res://assets/sprites/cloud.png"

var layers: Array[Parallax2D] = []

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
	
	for i in range(4):
		var cloud_sprite = Sprite2D.new()
		cloud_sprite.texture = preload(CLOUD_TEXTURE)
		cloud_sprite.position = Vector2(i * 400, -420 - (i % 2) * 140)
		cloud_layer.add_child(cloud_sprite)
	
	add_child(cloud_layer)
	layers.append(cloud_layer)
