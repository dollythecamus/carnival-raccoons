extends Label

var lines = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().call_group("Animals", "connect", "add_points", to_add_points)

func to_add_points(many, reason):
	var reason_text = ""
	match reason:
		Points.Reasons.Training:
			reason_text = "successfully training your animal!"
		Points.Reasons.Feeding:
			reason_text = "feeding!"
		Points.Reasons.Playing:
			reason_text = "playing the song!"
	
	var line = "Added " + str(many) + " points for " + reason_text + "\n"
	lines.append(line)
	text += line
	
	await get_tree().create_timer(1.0).timeout
	
	text = ""
	
