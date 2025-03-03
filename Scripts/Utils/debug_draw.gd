extends Node2D


func _draw() -> void:
	draw_line(Vector2(), get_global_mouse_position(), Color.WHITE, 1.0, false)
	for i in %Carnival.get_children():
		draw_line(Vector2(), i.global_position, Color.WHITE, 1.0, false)

func _process(delta: float) -> void:
	queue_redraw()
