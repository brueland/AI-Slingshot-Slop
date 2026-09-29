class_name Progress
extends RefCounted
## The player's saved progress: coins, upgrade levels and records. See docs/DESIGN.md section 9.

var coins: int = 0
var levels: Dictionary = {}          # upgrade id -> level (missing = 0)
var best_distance: float = 0.0
var total_runs: int = 0
var goal_reached: bool = false
var settings: Dictionary = {"music_volume": 0.8, "sfx_volume": 0.8}
var lifetime: Dictionary = {"distance": 0.0, "stars": 0, "bounces": 0, "best_height": 0.0}
var achievements: Array[String] = []
var recent_distances: Array[float] = []

const RECENT_RUNS: int = 10


func level_of(id: String) -> int:
	return int(levels.get(id, 0))


func add_coins(amount: int) -> void:
	if amount > 0:
		coins += amount


func next_cost(id: String) -> int:
	var level: int = level_of(id)
	return UpgradeCatalog.cost(id, level)


func can_buy(id: String) -> bool:
	var cost: int = next_cost(id)
	return cost >= 0 and coins >= cost


func buy(id: String) -> bool:
	if not can_buy(id):
		return false
	
	var cost: int = next_cost(id)
	coins -= cost
	levels[id] = level_of(id) + 1
	return true


func stats() -> PlayerStats:
	return PlayerStats.from_levels(levels)


func to_dict() -> Dictionary:
	return {
		"version": 1,
		"coins": coins,
		"levels": levels.duplicate(),
		"best_distance": best_distance,
		"total_runs": total_runs,
		"goal_reached": goal_reached,
		"settings": settings.duplicate(),
		"lifetime": lifetime.duplicate(),
		"achievements": achievements.duplicate(),
		"recent_distances": recent_distances.duplicate(),
	}


static func from_dict(data: Dictionary) -> Progress:
	var p := Progress.new()
	p.coins = maxi(0, int(data.get("coins", 0)))
	
	# Handle levels safely
	var levels_data = data.get("levels")
	if typeof(levels_data) == TYPE_DICTIONARY:
		p.levels = {}
		for key in levels_data:
			var key_str: String = str(key)
			if UpgradeCatalog.is_valid(key_str):
				var level: int = clampi(int(levels_data[key]), 0, UpgradeCatalog.max_level(key_str))
				if level > 0:
					p.levels[key_str] = level
	
	p.best_distance = maxf(0.0, float(data.get("best_distance", 0.0)))
	p.total_runs = maxi(0, int(data.get("total_runs", 0)))
	p.goal_reached = bool(data.get("goal_reached", false))
	
	# Handle settings safely
	var settings_data = data.get("settings")
	if typeof(settings_data) == TYPE_DICTIONARY:
		for key in ["music_volume", "sfx_volume"]:
			if settings_data.has(key):
				var value = float(settings_data[key])
				p.settings[key] = clampf(value, 0.0, 1.0)
	
	# Handle lifetime stats safely
	var lifetime_data = data.get("lifetime")
	if typeof(lifetime_data) == TYPE_DICTIONARY:
		p.lifetime["distance"] = maxf(0.0, float(lifetime_data.get("distance", 0.0)))
		p.lifetime["stars"] = maxi(0, int(lifetime_data.get("stars", 0)))
		p.lifetime["bounces"] = maxi(0, int(lifetime_data.get("bounces", 0)))
		p.lifetime["best_height"] = maxf(0.0, float(lifetime_data.get("best_height", 0.0)))
	
	# Handle achievements safely
	var achievements_data = data.get("achievements")
	if typeof(achievements_data) == TYPE_ARRAY:
		for value in achievements_data:
			var id: String = str(value)
			# Only add valid achievement IDs that are in the LIST
			var is_valid := false
			for entry in Achievements.LIST:
				if entry["id"] == id:
					is_valid = true
					break
			if is_valid and not p.achievements.has(id):
				p.achievements.append(id)
	
	# Handle recent distances safely
	var recent_distances_data = data.get("recent_distances")
	if typeof(recent_distances_data) == TYPE_ARRAY:
		for value in recent_distances_data:
			p.recent_distances.append(float(value))
		while p.recent_distances.size() > RECENT_RUNS:
			p.recent_distances.pop_front()
	
	return p


func record_run(distance: float, coins_earned: int) -> Array:
	var reached := Milestones.newly_reached(best_distance, distance)
	add_coins(coins_earned)
	for m in reached:
		add_coins(int(m["reward"]))
	total_runs += 1
	best_distance = maxf(best_distance, distance)
	if distance >= Balance.GOAL_DISTANCE:
		goal_reached = true
	return reached


func record_lifetime(result: Dictionary) -> void:
	lifetime["distance"] = float(lifetime["distance"]) + maxf(0.0, float(result.get("distance", 0.0)))
	lifetime["stars"] = int(lifetime["stars"]) + int(result.get("stars", 0))
	lifetime["bounces"] = int(lifetime["bounces"]) + int(result.get("bounces", 0))
	lifetime["best_height"] = maxf(float(lifetime["best_height"]), float(result.get("max_height", 0.0)))
	recent_distances.append(float(result.get("distance", 0.0)))
	while recent_distances.size() > RECENT_RUNS:
		recent_distances.pop_front()
