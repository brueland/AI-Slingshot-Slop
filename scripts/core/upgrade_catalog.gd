class_name UpgradeCatalog
extends RefCounted
## The 9 upgrades. See docs/DESIGN.md section 4.

const CATEGORIES: Array[String] = ["launcher", "projectile", "score"]
const CATEGORY_NAMES: Dictionary = {"launcher": "Slingshot", "projectile": "Projectile", "score": "Score"}

const UPGRADES: Dictionary = {
	"power": {"name": "Band Power", "category": "launcher", "max_level": 10, "base_cost": 80, "growth": 1.7,
		"per_level": 0.25, "description": "+25% launch speed per level"},
	"height": {"name": "Tall Frame", "category": "launcher", "max_level": 5, "base_cost": 60, "growth": 1.7,
		"per_level": 1.5, "description": "+1.5m launch height per level"},
	"guide": {"name": "Aim Guide", "category": "launcher", "max_level": 5, "base_cost": 25, "growth": 1.5,
		"per_level": 6, "description": "+6 guide points per level"},
	"aero": {"name": "Aerodynamics", "category": "projectile", "max_level": 5, "base_cost": 120, "growth": 1.8,
		"per_level": 0.18, "description": "-18% drag per level"},
	"bounce": {"name": "Bouncy Shell", "category": "projectile", "max_level": 5, "base_cost": 100, "growth": 1.8,
		"per_level": 0.08, "description": "+8% bounce factor per level"},
	"boosts": {"name": "Rocket Boosts", "category": "projectile", "max_level": 3, "base_cost": 300, "growth": 2.2,
		"per_level": 1, "description": "1 boost charge per level"},
	"multiplier": {"name": "Score Multiplier", "category": "score", "max_level": 5, "base_cost": 200, "growth": 1.9,
		"per_level": 0.25, "description": "+25% score per level"},
	"star_value": {"name": "Star Polish", "category": "score", "max_level": 5, "base_cost": 80, "growth": 1.7,
		"per_level": 5, "description": "+5 star value per level"},
	"bounce_bonus": {"name": "Style Points", "category": "score", "max_level": 5, "base_cost": 60, "growth": 1.7,
		"per_level": 3, "description": "+3 bonus points per bounce per level"}
}

static func ids() -> Array[String]:
	var result: Array[String] = []
	for id in UPGRADES:
		result.append(id)
	return result

static func is_valid(id: String) -> bool:
	return UPGRADES.has(id)

static func get_def(id: String) -> Dictionary:
	return UPGRADES.get(id, {})

static func max_level(id: String) -> int:
	var def: Dictionary = get_def(id)
	if def.size() == 0:
		return 0
	return def["max_level"]

static func ids_in_category(category: String) -> Array[String]:
	var result: Array[String] = []
	for id in UPGRADES:
		if UPGRADES[id]["category"] == category:
			result.append(id)
	return result

static func cost(id: String, level: int) -> int:
	if not is_valid(id) or level < 0 or level >= max_level(id):
		return -1
	var d := get_def(id)
	return roundi(float(d["base_cost"]) * pow(float(d["growth"]), level))

static func is_maxed(id: String, level: int) -> bool:
	return level >= max_level(id)
