#Player_Essentials(this is attached to the players Characterbody2d)
extends CharacterBody2D





@export var speed = 165
@export var jump_force = -300
@export var gravity = 1000
@export var crouch_speed = 80
@export var sprint_speed = 300


var current_state: PlayerState
var state_manager = PlayerState

func _ready():
	# Initialize the state machine
	 # Ensure PlayerStateManager initializes the state
	state_manager = get_node("PlayerState")
	
	if state_manager:
		state_manager.change_state("IdleState")

func _process(delta):
	if state_manager.current_state:
		state_manager.current_state.handle_input(delta) 

func _physics_process(delta):
	velocity.y += gravity * delta  # Apply gravity
	move_and_slide()
