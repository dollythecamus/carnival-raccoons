extends Camera2D

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("pan_camera_right"):
			drag_horizontal_offset = 1.0
		if event.is_action_pressed("pan_camera_left"):
			drag_horizontal_offset = -1.0
		if event.is_action_released("pan_camera_right") or event.is_action_released("pan_camera_left"):
			drag_horizontal_offset = 0.0
	
