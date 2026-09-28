class_name Scoring
extends RefCounted
## Score and coins for one run. See docs/DESIGN.md section 5.


static func compute(distance: float, stars: int, bounces: int, stats: PlayerStats) -> Dictionary:
	var distance_points: int = maxi(0, floori(distance))
	var star_points: int = stars * stats.star_value
	var bounce_points: int = bounces * stats.bounce_bonus
	var total: int = floori((distance_points + star_points + bounce_points) * stats.score_multiplier)
	
	return {
		"distance_points": distance_points,
		"star_points": star_points,
		"bounce_points": bounce_points,
		"total": total,
		"coins": total,
		"multiplier": stats.score_multiplier
	}
