extends PanelContainer

@onready var label = $Label

func _ready() -> void:
	get_tree().call_group("Animals", "connect", "DEBUG_stats_panel", display_stats_panel)

func display_stats_panel(which, dict):
	if not %UI.is_debug_mode:
		return
	
	label.text = ""
	for i in dict.size():
		var key = dict.keys()[i]
		var val = dict.values()[i]
		if val is float:
			val = round(val * 100) / 100
		label.text += key +": " + str(val) + "\n"
	self.position = which.global_position * UI.UI_SCALE
	show()
	await get_tree().create_timer(2.0).timeout
	hide() 
