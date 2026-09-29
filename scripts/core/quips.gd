class_name Quips
extends RefCounted
## What the alien says after a shot. The line depends on the kind of shot, and the same shot always gets the
## same line.

const LINES: Dictionary = {
	"best": ["Wheee! New record!", "I can see my house from here!", "Farther than ever. Again!"],
	"short": ["Was that a launch or a hiccup?", "I tripped.", "Pull harder, please!"],
	"stars": ["Shiny! I love stars.", "Star snacks for everyone!", "Twinkle twinkle, that was me."],
	"bouncy": ["Boing boing boing!", "I am a bouncy castle now.", "My antennae are dizzy."],
	"high": ["Hello, clouds!", "Is this space? It looks like space.", "My ears popped."],
	"default": ["Again! Again!", "That tickled.", "Not bad for a round alien.", "Grass stains. Worth it."],
}


static func kind_of(result: Dictionary) -> String:
	if bool(result.get("new_best", false)):
		return "best"
	if float(result.get("distance", 0.0)) < 15.0:
		return "short"
	if int(result.get("stars", 0)) >= 3:
		return "stars"
	if int(result.get("bounces", 0)) >= 5:
		return "bouncy"
	if float(result.get("max_height", 0.0)) >= 25.0:
		return "high"
	return "default"


static func pick(result: Dictionary) -> String:
	var lines: Array = LINES[kind_of(result)]
	var index := int(float(result.get("distance", 0.0)) * 10.0) % lines.size()
	return str(lines[index])
