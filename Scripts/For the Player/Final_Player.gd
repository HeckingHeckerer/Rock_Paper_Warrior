extends CharacterBody2D

@onready var animatedsprite = $AnimatedSprite2D
@export var speed = 165
@export var jump_force = -300

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var standing_cshape = preload("res://Rock_Paper_Warrior/Resources/mc_standing_idle_cshape.tres")
var crouching_cshape = preload("res://Rock_Paper_Warrior/Resources/mc_crouch_idle_cshape.tres")

var main_sm : LimboHSM

func _ready():
	initiate_state_machine()


func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = jump_force

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	
	flip_sprite(direction)
	move_and_slide()

func flip_sprite(direction):
	if direction == 1:
		animatedsprite.flip_h = false
		
	elif direction == -1:
		animatedsprite.flip_h = true
		
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("up"):
		main_sm.dispatch(&"to_jump")
	elif event.is_action_pressed("attack"):
		main_sm.dispatch(&"to_attack")

func _standing_cshape():
	collision_shape_2d.shape = standing_cshape
	collision_shape_2d.position.x = -39
	collision_shape_2d.position.y = -20

func initiate_state_machine(): #starts the state machine
	main_sm = LimboHSM.new()
	add_child(main_sm)
	
	
	#defining each state

	var idle_state = LimboState.new().named("idle").call_on_enter(idle_start).call_on_update(idle_update)
	var walk_state = LimboState.new().named("walk").call_on_enter(walk_start).call_on_update(walk_update)
	var jump_state = LimboState.new().named("jump").call_on_enter(jump_start).call_on_update(jump_update)
	var attack_state = LimboState.new().named("attack").call_on_enter(attack_start).call_on_update(attack_update)
	var crouch_state = LimboState.new().named("crouch").call_on_enter(crouch_start).call_on_update(crouch_update)
	var sprint_state = LimboState.new().named("sprint").call_on_enter(sprint_start).call_on_update(sprint_update)
	var wall_slide_state = LimboState.new().named("wall_slide").call_on_enter(wall_slide_start).call_on_update(wall_slide_update)
	var fall_state = LimboState.new().named("fall").call_on_enter(fall_start).call_on_update(fall_update)

	#add the child states
	main_sm.add_child(idle_state)
	main_sm.add_child(walk_state)
	main_sm.add_child(jump_state)
	main_sm.add_child(attack_state)
	main_sm.add_child(crouch_state)
	main_sm.add_child(sprint_state)
	main_sm.add_child(wall_slide_state)
	main_sm.add_child(fall_state)
	
	main_sm.initial_state = idle_state
	
	#transition state        #to          #from       #signal
	main_sm.add_transition(idle_state, walk_state, &"to_walk")
	main_sm.add_transition(main_sm.ANYSTATE, idle_state, &"state_ended") #note the state ended will go back to idle
	main_sm.add_transition(idle_state, jump_state, &"to_jump")
	main_sm.add_transition(walk_state, jump_state, &"to_jump")
	main_sm.add_transition(main_sm.ANYSTATE, attack_state, &"to_attack")
	main_sm.add_transition(attack_state,main_sm.ANYSTATE , &"to_normal_state")
	main_sm.add_transition(main_sm.ANYSTATE, fall_state, &"to_fall")
	
	
	main_sm.initialize(self)
	main_sm.set_active(true)
	
	
func idle_start():
	animatedsprite.play("Idle")
	print("entered idle")
func idle_update(delta : float):
	if velocity.x != 0:
		main_sm.dispatch(&"to_walk") #this will transfer to the walk state
	elif not is_on_floor() and velocity.y > 0 :
		_standing_cshape()
		main_sm.dispatch(&"to_fall")
		
	


func walk_start():
	animatedsprite.play("run")
	print("entered walk")
func walk_update(delta : float):
	if velocity.x == 0:
		main_sm.dispatch(&"state_ended")
	elif not is_on_floor() and velocity.y > 0 :
		_standing_cshape()
		main_sm.dispatch(&"to_fall")


func jump_start():
	animatedsprite.play("jump")
	velocity.y = jump_force
	print("entered jump")
	
	_standing_cshape()
		
		
	
	
func jump_update(delta : float):
	if is_on_floor():
		main_sm.dispatch(&"state_ended")
	elif not is_on_floor() and velocity.y > 0 :
		_standing_cshape()
		main_sm.dispatch(&"to_fall")
	
	
	
func fall_start():
	animatedsprite.play("fall")
	print("fall state")
	
	
func fall_update(delta : float):
	if is_on_floor():
		main_sm.dispatch(&"state_ended")
	
	
func attack_start():
	animatedsprite.play("attack")
	print("entered attack")
	
func attack_update(delta : float):
	pass
	

func crouch_start():
	pass
func crouch_update(delta : float):
	pass
	
	
func sprint_start():
	pass
func sprint_update(delta : float):
	pass
	
	
func wall_slide_start():
	pass
func wall_slide_update(delta : float):
	pass
	
	
