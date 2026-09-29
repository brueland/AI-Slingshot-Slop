class_name CourseView
extends Node2D
## Course items as sprites (stars, springs, mud) plus a flag at every milestone.

const TEXTURES: Dictionary = {
	"star": "res://assets/sprites/star.png",
	"spring": "res://assets/sprites/spring.png",
	"mud": "res://assets/sprites/mud.png",
}
const FLAG_TEXTURE: String = "res://assets/sprites/flag.png"
const GOAL_FLAG_TEXTURE: String = "res://assets/sprites/goal_flag.png"

var sprites: Array[Sprite2D] = []
var flags: Array[Sprite2D] = []


func _ready():
	for milestone in Milestones.LIST:
		var flag := Sprite2D.new()
		flag.texture = load(FLAG_TEXTURE)
		flag.position = WorldView.world_to_screen(Vector2(milestone["distance"], 0))
		flag.offset = Vector2(0, -35)
		add_child(flag)
		flags.append(flag)
		
		# If this is the goal milestone (1000m), use the goal flag texture
		if milestone["distance"] >= Balance.GOAL_DISTANCE:
			flag.texture = load(GOAL_FLAG_TEXTURE)


func build(items: Array) -> void:
	clear()
	
	for i in range(items.size()):
		var item: Dictionary = items[i]
		var sprite := Sprite2D.new()
		sprite.name = "Item%d" % i
		sprite.texture = load(TEXTURES[item["type"]])
		
		if item["type"] == "star":
			sprite.position = WorldView.world_to_screen(Vector2(item["x"], item["y"]))
			sprite.scale = Vector2(0.5, 0.5)
		elif item["type"] == "spring":
			sprite.position = WorldView.world_to_screen(Vector2(item["x"], 0))
			sprite.offset = Vector2(0, -35)
			sprite.scale = Vector2(0.6, 0.6)
		elif item["type"] == "mud":
			sprite.position = WorldView.world_to_screen(Vector2(item["x"] + Balance.MUD_WIDTH / 2.0, 0))
			sprite.scale = Vector2(Balance.MUD_WIDTH * 16 / 70, 0.3)
		
		add_child(sprite)
		sprites.append(sprite)


func mark_collected(index: int) -> void:
	if index >= 0 and index < sprites.size():
		sprites[index].visible = false


func item_count() -> int:
	return sprites.size()


func clear() -> void:
	for sprite in sprites:
		remove_child(sprite)
		sprite.free()
	sprites.clear()
