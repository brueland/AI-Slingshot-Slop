class_name HatBonuses
extends RefCounted
## Each hat gives the alien a small boost of its own, in its style: a nice extra, never a must.

## What each hat gives (hats not listed give nothing).
const LIST: Dictionary = {
	"party": "+2 points per bounce",
	"propeller": "+3% launch speed",
	"chef": "+2 star value",
	"top_hat": "+0.5 m launch height",
	"wizard": "-5% air drag",
	"crown": "+10% score",
	"cowboy": "+0.02 bounciness",
	"viking": "+0.4 m star reach",
	"beanie": "+2% launch speed, -2% air drag",
}


## What `hat_id` gives ("" for none).
static func text(hat_id: String) -> String:
	return str(LIST.get(hat_id, ""))


## Gives `stats` the boost of `hat_id` (in place) and returns them.
static func apply(stats: PlayerStats, hat_id: String) -> PlayerStats:
	match hat_id:
		"party":
			stats.bounce_bonus += 2
		"propeller":
			stats.max_speed *= 1.03
		"chef":
			stats.star_value += 2
		"top_hat":
			stats.launch_height += 0.5
		"wizard":
			stats.drag *= 0.95
		"crown":
			stats.score_multiplier += 0.1
		"cowboy":
			stats.restitution = minf(stats.restitution + 0.02, RoguePerks.MAX_RESTITUTION)
		"viking":
			stats.pickup_radius += 0.4
		"beanie":
			stats.max_speed *= 1.02
			stats.drag *= 0.98
	return stats
