extends Node2D
class_name Animal

@export_node_path("AnimatedSprite2D") var sprite_path
@export_node_path("AnimatedSprite2D") var paws_path

@onready var sprite = get_node(sprite_path)
@onready var paws = get_node(paws_path)

signal DEBUG_stats_panel(which, dict)

enum {Idle, Walking, Playing, Eating}
var state = Walking:
	set(v):
		prev_state = state
		state = v
var prev_state = Idle

signal play_note(note)
signal start_playing
signal interupt_music
signal add_points(many)

const IDLE_TRESHOLD = 0.5
const SPEED = 20
const EATING_TIME = 3.0
const HUNGRY_RATE = 0.05
var direction = 1.0

var boredom_rate = 0.2
var trained_score = 1.0
var wants_to_play = 1.0
var hunger = 0.5

var clock = 0.0
var clock_frequency = 2.0

var playing_instrument = null
var eating_food = null

func _ready() -> void:
	# connect to listen to the signal that the instrument sends to tell the animal it is close to one.
	# it is getting confusing to code this but with this system I can make it very modular to add
	# new instruments and animals 
	get_tree().call_group("Instrument", "connect", "animal_is_close", on_close_to_instrument)
	get_tree().call_group("Food", "connect", "animal_is_close", on_close_to_food)

func _process(delta: float) -> void:
	clock += delta
	if clock >= clock_frequency:
		clock = 0
		run_clock()
	
	match state:
		Idle:
			sprite.animation = "Idle"
			paws.visible = false
		
		Walking:
			
			sprite.play("Walking")
			paws.visible = false
			
			position.x += SPEED * direction * delta
			
			if direction < 0.0:
				sprite.flip_h = true
			elif direction > 0.0:
				sprite.flip_h = false
			
			wants_to_play += delta * boredom_rate * trained_score
			
			hunger += delta * HUNGRY_RATE
			
		Playing:
			sprite.animation = "Idle"
			paws.visible = true
			wants_to_play -= delta * boredom_rate * 1/trained_score
		Eating:
			sprite.animation = "Idle"
			paws.visible = true
			eating_food -= delta

func run_clock():
	mouse_hovering()
	
	match state:
		Idle:
			choose_random_direction()
			
			check_if_close_to_instrument()
			check_if_close_to_food()
			
			trained_score -= clamp(randf() - trained_score, 0.01, 1.0)
		Walking:
			choose_random_direction()
			
			check_if_close_to_instrument()
		Playing:
			check_if_close_to_food()
			if wants_to_play <= 0.1:
				state = Walking
				to_interupt_music()
			else:
				to_add_points(Points.PLAYING, Points.Reasons.Playing)
		Eating:
			if prev_state == Playing:
				trained_score += clamp(1.0 * trained_score, 0.01, 1.0)
				boredom_rate /= 1.5
				to_add_points(Points.TRAINING_TO_PLAY, Points.Reasons.Training)
			
			if eating_food < 0.0:
				state = Idle
			
			to_add_points(Points.FEEDING, Points.Reasons.Feeding)

func mouse_hovering():
	if global_position.distance_to(get_global_mouse_position()) < 30:
		var dict = {
			"trained score":trained_score,
			"hunger":hunger,
			"wants to play":wants_to_play,
			"boredom rate":boredom_rate,
			"state":str(state),
		}
		
		DEBUG_stats_panel.emit(self, dict)
		#emit_signal("display_stats_panel", self, dict)

func to_add_points(many, reason):
	add_points.emit(many, reason)
	#emit_signal("add_points", many, reason)

func to_interupt_music():
	if state == Playing:
		state = Walking
	interupt_music.emit()
	disconnect_from_instrument()

func choose_random_direction():
	direction = (randf() - 0.5) * 2
	
	if direction < IDLE_TRESHOLD and direction > -IDLE_TRESHOLD:
		state = Idle
	else:
		state = Walking

func on_play_note_once(note = 0):
	paws.play("Playing")
	play_note.emit(note)
	#emit_signal("play_note", note)
	await paws.frame_changed
	paws.pause()

func check_if_close_to_instrument():
	get_tree().call_group("Instrument", "is_animal_close", self)

func check_if_close_to_food():
	get_tree().call_group("Food", "is_animal_close", self)

func on_close_to_food(animal, food):
	if animal != self:
		return
	
	if hunger >= 0.5:
		if state == Playing:
			to_interupt_music()
		state = Eating
		eating_food = EATING_TIME
		food.position = position
		hunger -= food.filling
		food.is_being_eaten()

func on_close_to_instrument(animal, instrument):
	if animal != self:
		return
	
	if wants_to_play > 0.9 and not state == Playing:
		position = instrument.position + instrument.instrument_offset
		state = Playing
		playing_instrument = instrument
		if not is_connected("play_note", instrument.request_play):
			play_note.connect(instrument.request_play)
			instrument.grab.moved.connect(on_instrument_moved)
		start_playing.emit()
		#emit_signal("start_playing")

func on_instrument_moved(instrument):
	if instrument == playing_instrument:
		to_interupt_music()

func disconnect_from_instrument():
	if play_note.is_connected(playing_instrument.request_play):
		play_note.disconnect(Callable(playing_instrument.request_play))
	if playing_instrument.grab.moved.is_connected(on_instrument_moved):
		playing_instrument.grab.moved.disconnect(on_instrument_moved)
	playing_instrument = null
