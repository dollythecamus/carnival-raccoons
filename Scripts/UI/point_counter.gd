extends Label




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().call_group("Animals", "connect", "add_points", to_add_points)

func to_add_points(many, _reason):
	Points.points += many
	text = "Points: " + str(Points.points)
	
