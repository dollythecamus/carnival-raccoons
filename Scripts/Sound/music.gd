extends Node

@export var bpm = 200.0
@export var beat_loop = "abc0def012304560"
@export var bars = 4.0
@export var beats = 4.0
var beat_index = 0
@onready var beat_time = 60.0 / bpm
@onready var time_per_loop = beat_time * bars * beats

signal play_note(note)

func run_music_clock():
	if beat_index < 0:
		return
	
	var note = get_note(beat_index, beat_loop)
	if not note == -1:
		to_play_note(note)
	
	await get_tree().create_timer(beat_time).timeout
	
	beat_index += 1
	if beat_index >= bars * beats :
		beat_index = 0
	
	run_music_clock()

func get_note(i, loop):
	var r = loop[i]
	if r == "0":
		return -1
	else:
		return r.hex_to_int()

func interupt():
	beat_index = -5

func on_start_music():
	beat_index = 0
	await MusicSync.sync_loop
	run_music_clock()

func to_play_note(note):
	play_note.emit(note)
