extends Node2D
class_name Food

@onready var grab = $Grabbable
@export var filling = 1.0

const IS_ANIMAL_CLOSE_DISTANCE = 40.0

signal animal_is_close(animal, food)

func is_animal_close(which):
	if self.global_position.distance_to(which.global_position) < IS_ANIMAL_CLOSE_DISTANCE:
		animal_is_close.emit(which, self)
		#emit_signal("animal_is_close", which, self)

func is_being_eaten():
	$FX.show()
	await get_tree().create_timer(Animal.EATING_TIME).timeout
	queue_free()
