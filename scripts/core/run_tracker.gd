class_name RunTracker
extends RefCounted
## Applies course items (stars, springs, mud) to a flight after each step. See docs/DESIGN.md section 9.

signal star_collected(index: int)
signal spring_hit(index: int)
signal mud_hit(index: int)

var items: Array = []
var stars_collected: int = 0
var springs_hit: int = 0
var mud_hits: int = 0
var _used: Array[bool] = []


func _init(course_items: Array = []) -> void:
	items = course_items
	_used.resize(items.size())
	_used.fill(false)


func is_used(index: int) -> bool:
	if index < 0 or index >= _used.size():
		return false
	return _used[index]


func after_step(sim: FlightSim, previous_position: Vector2) -> void:
	for i in range(items.size()):
		if _used[i]:
			continue
		
		var item := items[i]
		var x := item["x"]
		
		# Skip items that are far from the projectile's path
		if x < previous_position.x - 10.0 or x > sim.position.x + 10.0:
			continue
			
		if item["type"] == "star":
			var star := Vector2(x, item["y"])
			var closest := Geometry2D.get_closest_point_to_segment(star, previous_position, sim.position)
			if closest.distance_to(star) <= Balance.STAR_RADIUS:
				_used[i] = true
				stars_collected += 1
				star_collected.emit(i)
