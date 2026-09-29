---
id: 090-quips
status: ready
tests: [tests/acceptance/test_090_quips.gd]
files: [scripts/core/quips.gd, scripts/ui/results_panel.gd]
---

# The alien talks

After a classic shot the results screen quotes the alien. The line depends on the kind of shot.

**1. Create the file `scripts/core/quips.gd` with exactly this code** (use that exact path as the edit's file name):
```gdscript
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
```

**2. `scripts/ui/results_panel.gd`** (keep everything else):
- **Declare** `var quip_label: Label` after `var title_label: Label`.
- In `_ready()`, right after `vbox.add_child(title_label)`:
  ```gdscript
  	quip_label = Label.new()
  	quip_label.add_theme_color_override("font_color", Color(0.75, 1.0, 0.85))
  	vbox.add_child(quip_label)
  ```
- In `show_result()`, right after the `title_label.text = ...` line:
  ```gdscript
  	var said := result.duplicate()
  	said["new_best"] = is_new_best
  	quip_label.text = "\"%s\"" % Quips.pick(said)
  ```

## Acceptance criteria
- Kinds in this order of priority: best, short (< 15 m), stars (3+), bouncy (5+ bounces), high (25+ m), default.
- `pick` returns line number `int(distance * 10) % count` of that kind.
- The results screen shows the line in double quotes under the title and still fits on screen.
