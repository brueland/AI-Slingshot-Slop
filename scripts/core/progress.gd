class_name Progress
extends RefCounted
## The player's saved progress: coins, upgrade levels and records. See docs/DESIGN.md section 9.

var coins: int = 0
var levels: Dictionary = {}          # upgrade id -> level (missing = 0)
var best_distance: float = 0.0
var total_runs: int = 0
var goal_reached: bool = false


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
