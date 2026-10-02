class_name TractorBeams
extends RefCounted
## The friendly UFOs' tractor beams: a cone of light from each UFO down to the ground. Flying into one pulls the alien
## gently up (less than gravity pulls it down, so it slows a fall and gives a little lift). The UFOs float here.

const SPOTS_M: Array[float] = [180.0, 420.0, 750.0, 1100.0, 1600.0]
const HEIGHT_M: float = 22.0
## Upward pull inside a beam (m/s per second); gravity is 15.
const PULL: float = 9.0
## Half the beam's width (meters) at the UFO and at the ground.
const TOP_HALF_WIDTH: float = 0.8
const BOTTOM_HALF_WIDTH: float = 3.0


## Is `point` (meters) inside one of the beams?
static func inside(point: Vector2) -> bool:
	if point.y <= 0.0 or point.y >= HEIGHT_M:
		return false
	var half := lerpf(BOTTOM_HALF_WIDTH, TOP_HALF_WIDTH, point.y / HEIGHT_M)
	for x in SPOTS_M:
		if absf(point.x - x) <= half:
			return true
	return false
