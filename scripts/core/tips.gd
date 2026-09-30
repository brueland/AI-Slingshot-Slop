class_name Tips
extends RefCounted
## Tips of the day for the title screen (the same tip all day).

const LIST: Array[String] = [
	"Tip: bigger aliens reach stars more easily (roguelike sizes).",
	"Tip: press R to repeat your last shot once you can see its line.",
	"Tip: fly into party balloons for a free lift.",
	"Tip: springs launch you high - aim for them!",
	"Tip: mud slows you down. Fly over it.",
	"Tip: the Daily Run is the same for everyone today.",
	"Tip: beat a boss round for an extra life.",
	"Tip: Headwind? Take Stronger Bands.",
	"Tip: sheep hop when you land next to them. Black sheep don't care.",
	"Tip: the arrow keys and Enter can aim and launch too.",
]


static func for_date(date: Dictionary) -> String:
	return LIST[posmod(Daily.seed_for(date), LIST.size())]
