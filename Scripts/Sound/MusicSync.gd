extends Node

signal sync_loop

var clock = 0.0
var sync = 2.0

func start_sync():
	clock = 0
	set_process(true)

func _process(delta: float) -> void:
	clock += delta
	if clock >= sync:
		clock = 0
		sync_loop.emit()
