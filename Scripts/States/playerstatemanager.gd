# Player State Manager (PlayerStateManager.gd)
extends Node

@export var initial_state: PlayerState

var current_state: PlayerState
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is PlayerState:
			states[child.name.to_lower()] = child
			
	
	if initial_state:
		change_state(initial_state.name)

func _process(delta):
	if current_state:
		current_state.handle_input(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func change_state(new_state_name: String):
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.exit_state()
	
	new_state.enter_state(get_parent())
	current_state = new_state
