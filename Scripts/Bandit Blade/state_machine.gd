extends Node

@export var initial_state : State

var current_state : State
var states: Dictionary = {}


func _ready():
	for child in get_children():
		if child is State: #Checks if a child is a state, if not for example: labels, sprites then false
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			
	if initial_state:
		initial_state.enter()
		current_state = initial_state
		

func _process(delta):
	if current_state: #this is not a boolean value, it just checks if state is empty or not
		current_state.update(delta) #this will start the current state, if state is running then this will run "running"
	
func _physics_process(delta: float):
	if current_state:
		current_state.physiscs_update(delta)
		
		
func on_child_transition(state, new_state_name):
	if state != current_state: #stops a state if it is not the active state, for examplestate == JumpState and current_state == IdleState
		return
		
	var new_state = states.get(new_state_name.lower())
	if !new_state:
		return
		
	if current_state:
		current_state.exit()
		
	new_state.enter()
	
	current_state = new_state
