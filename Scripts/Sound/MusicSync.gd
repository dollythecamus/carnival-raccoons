extends Node

signal sync_loop

var clock = 0.0
var sync = 2.0

var playing = false


func start_sync():
	clock = 0
	sync_loop.emit()
	playing = true
	set_process(true)

func stop_sync():
	playing = false

func _process(delta: float) -> void:
	set_process(playing)
	clock += delta
	if clock >= sync:
		clock = 0
		sync_loop.emit()
