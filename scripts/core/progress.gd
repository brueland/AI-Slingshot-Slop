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
