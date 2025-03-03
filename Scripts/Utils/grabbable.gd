extends Node

@export var enabled = false
@export var is_parent_grabbable = false
@export_node_path("Node") var node_to_grabbable 

signal moved(node)

var is_grabbed = false:
	set(v):
		is_grabbed = v
		if is_grabbed:
			get_tree().call_group("Grabbable", "unstuck", self) # fixed stuck
const GRAB_SPEED = 2000.0
@export var grab_size = 32
var velocity = Vector2()

var node = null

func _ready():
	if enabled:
		add_to_group("Grabbable")
	
	set_process(enabled)
	set_process_input(enabled)
	
	if is_parent_grabbable:
		node = get_parent()
	else:
		node = get_node(node_to_grabbable)

func _input(event: InputEvent):
	# check if mouse clicked on it, drag and drop it to give to raccoon.
	if event is InputEventMouseButton:
		if event.is_action_pressed("Grab"):
			if node.global_position.distance_to(node.get_global_mouse_position()) < grab_size:
				is_grabbed = true
		if event.is_action_released("Grab"):
			is_grabbed = false
			moved.emit(self)

func _process(delta: float) -> void:
	if is_grabbed:
		var target = node.get_global_mouse_position()
		var distance = node.position.distance_to(target)
		velocity = node.position.direction_to(target) * GRAB_SPEED * distance * delta
		node.position += velocity * delta

func unstuck(which):
	if which != self:
		is_grabbed = false
