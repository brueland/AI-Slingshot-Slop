class_name RunTracker
extends RefCounted
## Applies course items (stars, springs, mud) to a flight after each step. See docs/DESIGN.md section 9.

signal star_collected(index: int)
signal spring_hit(index: int)
signal mud_hit(index: int)

## A spring fires when the alien comes this low over it (meters above the ground), not only on the ground.
const SPRING_TOP: float = 0.6

var items: Array = []
var stars_collected: int = 0
var springs_hit: int = 0
var mud_hits: int = 0
var pickup_offset: float = 0.0
var pickup_radius: float = Balance.STAR_RADIUS
var _used: Array[bool] = []


func _init(course_items: Array = [], p_pickup_offset: float = 0.0, p_pickup_radius: float = Balance.STAR_RADIUS) -> void:
	items = course_items
	pickup_offset = p_pickup_offset
	pickup_radius = p_pickup_radius
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
		
		var item: Dictionary = items[i]
		var x: float = item["x"]
		
		# Skip items that are far from the projectile's path
		if x < previous_position.x - 10.0 or x > sim.position.x + 10.0:
			continue
			
		match item["type"]:
			"star":
				var star: Vector2 = Vector2(x, item["y"])
				var lift := Vector2(0.0, pickup_offset)
				var closest := Geometry2D.get_closest_point_to_segment(star, previous_position + lift, sim.position + lift)
				if closest.distance_to(star) <= pickup_radius:
					_used[i] = true
					stars_collected += 1
					star_collected.emit(i)
			"spring":
				# the alien's side touching the spring counts: its body reaches 0.8 x pickup_offset to each side
				var reach := Balance.SPRING_HALF_WIDTH + pickup_offset * 0.8
				if sim.position.y <= sim.ground_height(x) + SPRING_TOP and absf(sim.position.x - x) <= reach:
					_used[i] = true
					sim.velocity.y = maxf(sim.velocity.y, Balance.SPRING_SPEED)
					sim.velocity.x += Balance.SPRING_PUSH
					sim.stopped = false
					springs_hit += 1
					spring_hit.emit(i)
			"mud":
				if sim.position.y <= sim.ground_height(sim.position.x) + 0.01 and sim.position.x >= x and sim.position.x <= x + Balance.MUD_WIDTH:
					_used[i] = true
					sim.velocity.x *= Balance.MUD_FACTOR
					mud_hits += 1
					mud_hit.emit(i)
