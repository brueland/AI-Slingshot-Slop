extends GutTest
# Task 119: the perk panel shows a boss goal in red, and says "Boss beaten! +1 life" after one is beaten.

const PANEL := "res://scripts/ui/rogue_panel.gd"
const RUN := "res://scripts/core/rogue_run.gd"


func test_boss_on_the_panel() -> void:
	var p = load(PANEL).new()
	add_child_autofree(p)
	var r = load(RUN).new()
	r.start(7)
	r.round_number = 11
	r.goal = {"type": "distance", "target": 10.0, "round": 11, "text": "Fly at least 10 m"}
	var out: Dictionary = r.finish_shot({"distance": 50.0})
	p.show_outcome(out, r)
	assert_eq(p.title_label.text, "Goal met!")
	assert_true(p.goal_label.text.begins_with("Next goal: BOSS: "))
	assert_eq(p.goal_label.modulate, Color(1.0, 0.6, 0.6), "a boss goal is shown in red")
	r.choose_perk(r.offer[0])
	var everything := {"distance": 99999.0, "max_height": 999.0, "bounces": 99, "stars": 99}
	for part in r.goal["parts"]:
		if part["type"] == "zone":
			everything["distance"] = float(part["target"]) + 1.0
	out = r.finish_shot(everything)
	p.show_outcome(out, r)
	assert_eq(p.title_label.text, "Boss beaten! +1 life")
	assert_eq(p.goal_label.modulate, Color.WHITE, "normal goals are white")
