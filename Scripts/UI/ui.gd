extends Control
class_name UI

var tt = preload("res://Scenes/Carnival/TastyTreat.tscn").instantiate()

const UI_SCALE = 3
var is_debug_mode = false

func _on_buy_treat_pressed() -> void:
	var new_tt = tt.duplicate()
	new_tt.position = get_global_mouse_position()
	new_tt.grab.is_grabbed = true
	%Carnival.add_child(new_tt)
	Points.points -= 10


func _on_debug_toggled(toggled_on: bool):
	is_debug_mode = toggled_on
	%debug_draw.visible = toggled_on
