class_name ShopPanel
extends PanelContainer
## Upgrade shop: one button per upgrade.

signal purchase_requested(id: String)
signal launch_requested

var buttons: Dictionary = {}      # upgrade id -> Button
var list: VBoxContainer

func _ready():
	# Center the panel like results panel
	custom_minimum_size = Vector2(520, 0)
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	
	# Create the list container
	list = VBoxContainer.new()
	list.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(list)
	
	# Add buttons for each upgrade
	for id in UpgradeCatalog.ids():
		var button := Button.new()
		button.name = id
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		buttons[id] = button
		button.pressed.connect(func(): purchase_requested.emit(id))
		list.add_child(button)
	
	hide()


func refresh(progress: Progress) -> void:
	for id in UpgradeCatalog.ids():
		var d := UpgradeCatalog.get_def(id)
		var level := progress.level_of(id)
		var cost := progress.next_cost(id)
		
		if cost < 0:
			buttons[id].text = "%s  Lv %d/%d  MAX" % [d["name"], level, int(d["max_level"])]
		else:
			buttons[id].text = "%s  Lv %d/%d  %d coins" % [d["name"], level, int(d["max_level"]), cost]
		
		buttons[id].disabled = not progress.can_buy(id)
		buttons[id].tooltip_text = str(d["description"])
