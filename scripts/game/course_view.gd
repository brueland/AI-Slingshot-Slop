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
var best_marker: Sprite2D
var best_label: Label
var star_indices: Array[int] = []
var time: float = 0.0


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
		
	best_marker = Sprite2D.new()
	best_marker.texture = load(FLAG_TEXTURE)
	best_marker.modulate = Color(1.0, 0.85, 0.3)
	best_marker.offset = Vector2(0, -35)
	best_marker.hide()
	add_child(best_marker)
	best_label = Label.new()
	best_label.position = Vector2(-40, -110)
	best_label.add_theme_font_size_override("font_size", 18)
	best_label.add_theme_constant_override("outline_size", 4)
	best_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	best_marker.add_child(best_label)


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
			star_indices.append(i)
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


func set_best_marker(distance: float) -> void:
	if distance <= 0.0:
		best_marker.hide()
		return
	best_marker.position = WorldView.world_to_screen(Vector2(distance, 0.0))
	best_label.text = "Best: %d m" % floori(distance)
	best_marker.show()


func _process(delta: float) -> void:
	advance(delta)


## Stars gently pulse and the milestone flags sway.
func advance(delta: float) -> void:
	time += delta
	for i in star_indices:
		if i < sprites.size():
			sprites[i].scale = Vector2(0.5, 0.5) * (1.0 + 0.1 * sin(time * 4.0 + i))
	for k in flags.size():
		flags[k].rotation = sin(time * 2.0 + k) * 0.06


func clear() -> void:
	for sprite in sprites:
		remove_child(sprite)
		sprite.free()
	sprites.clear()
	star_indices.clear()
