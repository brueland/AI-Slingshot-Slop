class_name ResultsPanel
extends PanelContainer
## The score breakdown after a run.

signal continue_pressed

var title_label: Label
var quip_label: Label
var distance_label: Label
var stars_label: Label
var bounces_label: Label
var multiplier_label: Label
var total_label: Label
var coins_label: Label
var milestones_label: Label
var hats_label: Label
var balloons_label: Label
var shot_map: ShotMap
var gap_label: Label
var continue_button: Button

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(420, 0)
	
	var vbox := VBoxContainer.new()
	add_child(vbox)
	
	title_label = Label.new()
	vbox.add_child(title_label)
	
	quip_label = Label.new()
	quip_label.add_theme_color_override("font_color", Color(0.75, 1.0, 0.85))
	vbox.add_child(quip_label)
	
	shot_map = ShotMap.new()
	vbox.add_child(shot_map)
	
	gap_label = Label.new()
	gap_label.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	vbox.add_child(gap_label)
	
	distance_label = Label.new()
	vbox.add_child(distance_label)
	
	stars_label = Label.new()
	vbox.add_child(stars_label)
	
	bounces_label = Label.new()
	vbox.add_child(bounces_label)
	
	multiplier_label = Label.new()
	vbox.add_child(multiplier_label)
	
	total_label = Label.new()
	vbox.add_child(total_label)
	
	coins_label = Label.new()
	vbox.add_child(coins_label)
	
	milestones_label = Label.new()
	milestones_label.visible = false
	vbox.add_child(milestones_label)
	
	hats_label = Label.new()
	hats_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	hats_label.visible = false
	vbox.add_child(hats_label)
	
	balloons_label = Label.new()
	balloons_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.85))
	balloons_label.visible = false
	vbox.add_child(balloons_label)
	
	continue_button = Button.new()
	continue_button.text = "Continue"
	continue_button.connect("pressed", Callable(self, "_on_continue_pressed"))
	vbox.add_child(continue_button)
	
	hide()

func _on_continue_pressed():
	emit_signal("continue_pressed")

func show_result(result: Dictionary, is_new_best: bool) -> void:
	title_label.text = "New best!" if is_new_best else "Run complete"
	var said := result.duplicate()
	said["new_best"] = is_new_best
	quip_label.text = "\"%s\"" % Quips.pick(said)
	var path: PackedVector2Array = result.get("path", PackedVector2Array())
	shot_map.set_path(path)
	var previous := float(result.get("previous_best", 0.0))
	var flown := float(result.get("distance", 0.0))
	if is_new_best and previous > 0.0:
		gap_label.text = "New best by %d m!" % roundi(flown - previous)
	elif not is_new_best and previous > 0.0:
		gap_label.text = "%d m short of your best (%d m)" % [roundi(previous - flown), roundi(previous)]
	else:
		gap_label.text = ""
	gap_label.visible = gap_label.text != ""
	distance_label.text = "Distance: %d m" % result["distance_points"]
	stars_label.text = "Stars: %d (+%d)" % [result["stars"], result["star_points"]]
	bounces_label.text = "Bounces: %d (+%d)" % [result["bounces"], result["bounce_points"]]
	multiplier_label.text = "Multiplier: x%.2f" % result["multiplier"]
	total_label.text = "Total: %d" % result["total"]
	coins_label.text = "Coins earned: +%d" % result["coins"]
	
	if result.has("milestones") and result["milestones"].size() > 0:
		var milestone_texts := []
		for milestone in result["milestones"]:
			milestone_texts.append("Milestone reached: %s (+%d)" % [milestone["name"], milestone["reward"]])
		milestones_label.text = "\n".join(milestone_texts)
		milestones_label.visible = true
	else:
		milestones_label.text = ""
		milestones_label.visible = false
	
	var new_hats: Array = result.get("new_hats", [])
	var names := PackedStringArray()
	for id in new_hats:
		names.append(str(Hats.get_def(str(id)).get("name", id)))
	hats_label.text = "New hat: %s! Try it on in the Wardrobe" % ", ".join(names)
	hats_label.visible = not new_hats.is_empty()
	var popped := int(result.get("balloons", 0))
	balloons_label.text = "Balloons popped: %d" % popped
	balloons_label.visible = popped > 0
	
	show()
