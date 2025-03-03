extends Node2D
class_name Instrument

@export var instrument_offset : Vector2
@export var instrument_type : TYPES
@export var varying_pitch = 0.0

@onready var grab = $Grabbable

enum TYPES {Percursion, Strings, Keys}

signal animal_is_close(animal, instrument)

const NOTE_SCALE = 1.05946
const IS_ANIMAL_CLOSE_DISTANCE = 30.0

func request_play(note = 0):
	$Audio.play(0.0)
	var pitch_variation = remap(randf() , 0.0, 1.0, 1.0 - varying_pitch, 1.0 + varying_pitch)
	match instrument_type:
		TYPES.Keys:
			$Audio.pitch_scale = NOTE_SCALE * note
		TYPES.Percursion:
			$Audio.pitch_scale = pitch_variation

func is_animal_close(which):
	if self.global_position.distance_to(which.global_position) < IS_ANIMAL_CLOSE_DISTANCE:
		animal_is_close.emit(which, self)
