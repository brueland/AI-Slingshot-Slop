class_name Terrain
extends RefCounted
## How hilly the ground is: the height (meters) of the rolling hills FlightSim.terrain_height draws. Flat at first,
## then a little hillier as the game goes on, up to MAX_HILLS (always gentle: a slope of at most about 0.2).

const MAX_HILLS: float = 2.5


## Roguelike: flat for the first two rounds, then 0.12 m more every round.
static func for_round(round_number: int) -> float:
	return clampf(0.12 * (round_number - 2), 0.0, MAX_HILLS)


## Classic: 0.25 m more for every 100 m of the best distance.
static func for_best_distance(best: float) -> float:
	return clampf(best / 400.0, 0.0, MAX_HILLS)
