extends CharacterBody2D

@onready var animatedsprite = $AnimatedSprite2D
@export var speed = 165
@export var jump_force = -300
const crouch_speed = 80
const sprint_speed = 300

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var standing_cshape = preload("res://Rock_Paper_Warrior/Resources/mc_standing_idle_cshape.tres")
var crouching_cshape = preload("res://Rock_Paper_Warrior/Resources/mc_crouch_idle_cshape.tres")

var main_sm : LimboHSM
var direction : float

func _ready():
	initiate_state_machine()


func _physics_process(delta: float) -> void:
	#print(main_sm.get_active_state())
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = jump_force

	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("left", "right")
	#
	#if direction:
		#velocity.x = direction * speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed)
		
	main_sm.update(delta)
		
	

	
	
	
	move_and_slide()

func flip_sprite(direction):
	if direction == 1:
		animatedsprite.flip_h = false
		
	elif direction == -1:
		animatedsprite.flip_h = true
		
func _unhandled_input(event: InputEvent):
	
	if event.is_action_pressed("up"):
		main_sm.dispatch(&"to_jump")
	if event.is_action_pressed("sprint") and abs(Input.get_axis("left", "right")) > 0.1:
		main_sm.dispatch(&"to_sprint")
	elif event.is_action_pressed("left") or  event.is_action_pressed("right"):
		main_sm.dispatch(&"to_walk")
	elif event.is_action_pressed("attack"):
		main_sm.dispatch(&"to_attack")
	#elif event.is_action_pressed("crouch_idle"):
		#if (Input.is_action_pressed("left") or Input.is_action_pressed("right")) :
			#print("CROUCH")
			#main_sm.dispatch(&"to_crouch_walk")
		#else:
			#main_sm.dispatch(&"to_crouch")
	elif event.is_action_released("crouch_idle"):
		main_sm.dispatch(&"state_ended")
	
	
	
	
			

func _standing_cshape():
	collision_shape_2d.shape = standing_cshape
	collision_shape_2d.position.x = -39
	collision_shape_2d.position.y = -20
	
func _crouching_cshape():
	collision_shape_2d.shape = crouching_cshape
	
	collision_shape_2d.position.x = -39
	collision_shape_2d.position.y = -14

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
	var crouch_walk_state = LimboState.new().named("crouch_walk").call_on_enter(crouch_walk_start).call_on_update(crouch_walk_update)

	#add the child states
	main_sm.add_child(idle_state)
	main_sm.add_child(walk_state)
	main_sm.add_child(jump_state)
	main_sm.add_child(attack_state)
	main_sm.add_child(crouch_state)
	main_sm.add_child(crouch_walk_state)
	main_sm.add_child(sprint_state)
	main_sm.add_child(wall_slide_state)
	main_sm.add_child(fall_state)
	
	
	main_sm.initial_state = idle_state
	
	#transition state        #from         #to        #signal
	main_sm.add_transition(main_sm.ANYSTATE, idle_state, &"state_ended") #note the state ended will go back to idle
	main_sm.add_transition(main_sm.ANYSTATE, attack_state, &"to_attack")
	main_sm.add_transition(main_sm.ANYSTATE, fall_state, &"to_fall")
	main_sm.add_transition(main_sm.ANYSTATE, crouch_state, &"to_crouch")
	
	
	
	main_sm.add_transition(idle_state, walk_state, &"to_walk")
	main_sm.add_transition(jump_state, walk_state, &"to_walk")
	
	main_sm.add_transition(idle_state, jump_state, &"to_jump")
	main_sm.add_transition(walk_state, jump_state, &"to_jump")
	main_sm.add_transition(sprint_state, jump_state, &"to_jump")
	
	main_sm.add_transition(idle_state, sprint_state, &"to_sprint")
	main_sm.add_transition(walk_state, sprint_state, &"to_sprint")
	
	#crouching
	main_sm.add_transition(crouch_state, crouch_walk_state, &"to_crouch_walk")
	main_sm.add_transition(crouch_walk_state, crouch_state, &"to_crouch")
	main_sm.add_transition(walk_state, crouch_walk_state, &"to_crouch_walk")
	
	main_sm.add_transition(attack_state,main_sm.ANYSTATE , &"to_normal_state")
	
	
	
	
	
	
	
	
	
	main_sm.initialize(self)
	main_sm.set_active(true)
	
	
func idle_start():
	animatedsprite.play("Idle")
	print("entered idle")
func idle_update(delta : float):
	_standing_cshape()
	velocity.x = 0  # Stop movement in idle
	if Input.get_axis("left", "right"):
		main_sm.dispatch(&"to_walk")
	
		
		#===================CHECK FALL=====================
	elif not is_on_floor() and velocity.y > 0 :
		
		main_sm.dispatch(&"to_fall")
	elif  not is_on_floor() and velocity.y < 0: 
		
		
		main_sm.dispatch(&"to_jump")
		
	


func walk_start():
	animatedsprite.play("run")
	print("entered walk")
func walk_update(delta : float):
	
	_standing_cshape()
	direction = Input.get_axis("left", "right")
	
	velocity.x = direction * speed
	
		
	
	flip_sprite(direction)
	
	if velocity.x == 0:
		main_sm.dispatch(&"state_ended")
		#===================CHECK FALL=====================
	elif not is_on_floor() and velocity.y > 0 :
		
		main_sm.dispatch(&"to_fall")
	elif  not is_on_floor() and velocity.y < 0: 
		
		
		main_sm.dispatch(&"to_jump")
	
	elif Input.is_action_pressed("crouch_idle") :
		if abs(Input.get_axis("left", "right")):
			main_sm.dispatch(&"to_crouch_walk")
			
		else:
			main_sm.dispatch(&"to_crouch")


func jump_start():
	animatedsprite.play("jump")
	
	
	print("Enter_JU8mp")
	
	if is_on_floor():
		velocity.y = jump_force
	
	
func jump_update(delta : float):
	
	#JUMP SPRINT TIMER NOT EMPLEMENTED, YOU NEED ATLEAST 1.5 SECONDS IN ORDER TO DO SRPINT JUMP
	
	_standing_cshape()
	direction = Input.get_axis("left", "right")
	
	flip_sprite(direction)
	
	
	if Input.is_action_pressed("sprint") and Input.is_action_pressed("up"):
		velocity.x = direction * sprint_speed
	elif Input.is_action_just_released("left") and Input.is_action_just_released("right"):
		main_sm.dispatch(&"state_ended")
	elif Input.is_action_pressed("up"):
		velocity.x = direction * speed
	
	if is_on_floor():
		main_sm.dispatch(&"state_ended")
		#===================CHECK FALL=====================
	elif not is_on_floor() and velocity.y > 0 :
		_standing_cshape()
		main_sm.dispatch(&"to_fall")
	
	
	
func fall_start():
	animatedsprite.play("fall")
	print("fall state")
	
	
func fall_update(delta : float):
	
	_standing_cshape()
	direction = Input.get_axis("left", "right")
	velocity.x = direction * speed
	flip_sprite(direction)
	
	if is_on_floor():
		main_sm.dispatch(&"state_ended")
	
	
func attack_start():

	var random_chance = randf()
	
	# 50% chance for each animation
	if random_chance < 0.5:
		animatedsprite.play("attack")
	else:
		animatedsprite.play("attack_2")
		
	print("entered attack")
	animatedsprite.animation_finished.connect(_on_attack_finished)

func attack_update(delta : float):
	
	_standing_cshape()
	direction = Input.get_axis("left", "right")
	velocity.x = direction * speed
	flip_sprite(direction)
	
	#if animatedsprite.animation != "attack" :
		#main_sm.dispatch(&"state_ended")
		
	if animatedsprite.animation != "attack" and animatedsprite.animation != "attack_2":
		main_sm.dispatch(&"state_ended")
	
func _on_attack_finished():
	if animatedsprite.animation == "attack" :  # Ensure it's the attack animation that finished
		print("Attack animation finished, returning to idle")
		main_sm.dispatch(&"state_ended")  # Go back to idle state
	elif animatedsprite.animation == "attack_2":
		print("Attack_TWO animation finished, returning to idle")
		main_sm.dispatch(&"state_ended")
		
	
	

func crouch_start():
	animatedsprite.play("crouch_idle")
	print("entered crouch")
	
func crouch_update(delta : float):
	
	
	_crouching_cshape()
	direction = Input.get_axis("left", "right")
	flip_sprite(direction)
	
	 
	
	
	
	
func crouch_walk_start():
	animatedsprite.play("crouch_walk")
	print("entered crouch walk")
func crouch_walk_update():
	_crouching_cshape()
	print("CORUCHAUDSW")
	direction = Input.get_axis("left", "right")
	
	flip_sprite(direction)
	
	

	
	
func sprint_start():
	animatedsprite.play("sprint")
	print("ente3red sprint")
func sprint_update(delta : float):
	
	_standing_cshape()
	direction = Input.get_axis("left", "right")
	velocity.x = direction * sprint_speed
	flip_sprite(direction)
	
	if Input.is_action_just_released("sprint"):
		main_sm.dispatch(&"state_ended")
	elif  not is_on_floor() and velocity.y < 0: 
		
		
		main_sm.dispatch(&"to_jump")
	
func wall_slide_start():
	pass
func wall_slide_update(delta : float):
	pass
	
	
