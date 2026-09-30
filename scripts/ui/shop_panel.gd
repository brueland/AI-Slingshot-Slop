class_name ShopPanel
extends PanelContainer
## Upgrade shop: one button per upgrade.

signal purchase_requested(id: String)
signal launch_requested

var buttons: Dictionary = {}      # upgrade id -> Button
var header_labels: Dictionary = {}   # category -> Label
var coins_label: Label
var launch_button: Button
var list: VBoxContainer
var best_buy: String = ""

func _ready():
	# Center the panel like results panel
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	custom_minimum_size = Vector2(520, 0)
	
	# Create the list container
	list = VBoxContainer.new()
	list.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(list)
	
	# Add coins label
	coins_label = Label.new()
	coins_label.add_theme_font_size_override("font_size", 26)
	list.add_child(coins_label)
	
	# Add headers and buttons for each category
	for category in UpgradeCatalog.CATEGORIES:
		# Add header label
		var header_label := Label.new()
		header_label.text = UpgradeCatalog.CATEGORY_NAMES[category]
		header_label.add_theme_font_size_override("font_size", 22)
		header_labels[category] = header_label
		list.add_child(header_label)
		
		# Add buttons for this category
		for id in UpgradeCatalog.ids_in_category(category):
			var button := Button.new()
			button.name = id
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			buttons[id] = button
			button.pressed.connect(func(): purchase_requested.emit(id))
			list.add_child(button)
	
	# Add launch button
	launch_button = Button.new()
	launch_button.text = "Launch!"
	launch_button.pressed.connect(func(): launch_requested.emit())
	list.add_child(launch_button)
	
	hide()


func refresh(progress: Progress) -> void:
	coins_label.text = "Coins: %d" % progress.coins
	
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
	best_buy = ""
	for id in UpgradeCatalog.ids():
		if progress.can_buy(id) and (best_buy == "" or progress.next_cost(id) < progress.next_cost(best_buy)):
			best_buy = id
	for id in UpgradeCatalog.ids():
		buttons[id].modulate = Color(0.75, 1.0, 0.75) if id == best_buy else Color.WHITE
