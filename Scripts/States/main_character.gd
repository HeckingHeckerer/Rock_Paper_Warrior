extends CharacterBody2D  # Use CharacterBody2D in Godot 4

@export var speed = 165
@export var jump_force = -300
@export var gravity = 1000

@export var play_roll_animation_timer = 1 #the duration the animation plays
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var wallclimb_jumpforce = -200

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var play_roll_timer: Timer = $"play roll timer" #as timer runs, all animations are overwrited and replaced ny the roll duration for as long as the timer

var current_state
var last_facing_direction = 1

var is_wall_sliding = false 
const crouch_speed = 80
const sprint_speed = 300


@export var wall_slide_delay = 0.25  # Time before sliding starts
@onready var wall_slide_timer: Timer = $"wall slide timer"
var can_wall_slide = false  # Prevents wall slide before 1s
const wall_slide_gravity = 100 #A cool mechanic if u set this to 0 it will stick to the wall




#loading collision shapes
var standing_cshape = preload("res://Rock_Paper_Warrior/Resources/mc_standing_idle_cshape.tres")
var crouching_cshape = preload("res://Rock_Paper_Warrior/Resources/mc_crouch_idle_cshape.tres")




func _ready():
	# Connect the timer's timeout signal to a function
	wall_slide_timer.wait_time = wall_slide_delay
	wall_slide_timer.one_shot = true
	wall_slide_timer.timeout.connect(_on_wall_slide_timer_timeout)
	

func change_state(new_state_name : String):
	
	if current_state:
		current_state.exit_state()
	current_state = get_node(new_state_name)
	if current_state:
		current_state.enter_state(self)
			
			
func _process(delta):
	pass	
	#For Input, Shaders, Camera controls, UI, Animations
	
	
func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta  
	
	_jump()
	_wall_sliding()
	

	# Move left/right
	#======================================
	
	var direction = Input.get_axis("left", "right") 
	velocity.x = direction * speed
	
	
	if direction != 0:
		last_facing_direction = sign(direction)
		
	
	if current_state:
		current_state.handle_input(delta)
		
	
	

	if direction > 0:
		_standing_cshape()
		animated_sprite_2d.flip_h = false
		
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		
		
	#======================================
	
	#Attack
	#=======================================
	#if Input.is_action_pressed("attack"):
		#_attack()
		#isAttacking = true

	# Wall sliding Logic
	#=============================
	if can_wall_slide and is_on_wall_only():
		is_wall_sliding = true
		velocity.y += wall_slide_gravity * delta
		velocity.y = min(velocity.y, wall_slide_gravity)

	# Wall sliding animation
	if is_wall_sliding:
		if direction > 0:
			animated_sprite_2d.flip_h = true
			animated_sprite_2d.play("wall_slide")
			_standing_cshape()
		elif direction < 0:
			animated_sprite_2d.flip_h = false
			animated_sprite_2d.play("wall_slide")
			_standing_cshape()
	#=============================

	# All animations regarding if the player is on the floor
	elif is_on_floor():

		# All Crouching
		#+======================================================
		# Crouch walking
		if Input.is_action_pressed("crouch_idle") and (Input.is_action_pressed("left") or Input.is_action_pressed("right")) :
			velocity.x = direction * crouch_speed
			animated_sprite_2d.play("crouch_walk")
			_crouching_cshape()

		# Crouching idle
		elif Input.is_action_pressed("crouch_idle"):
			animated_sprite_2d.play("crouch_idle")
			_crouching_cshape()
			#if released ctrl, the collision will go back to standing
		elif Input.is_action_just_released("crouch_idle"):
			_standing_cshape()
		#+======================================================

		# Sprinting
		#+======================================================
		elif Input.is_action_pressed("sprint") and Input.is_action_pressed("left")  or Input.is_action_pressed("right") and Input.is_action_pressed("sprint") :
			velocity.x = direction * sprint_speed
			animated_sprite_2d.play("sprint")
			_standing_cshape()
		#+======================================================

		# Standing idle
		#+======================================================
		elif direction == 0:
			animated_sprite_2d.play("Idle")
			if direction > 0:
				_standing_cshape()
				
				
			elif direction < 0:
				_standing_cshape()
			
				
		#+======================================================

		# Running
		#+======================================================
		else:
			animated_sprite_2d.play("run")
			_standing_cshape()
			
		#+======================================================

	# Jumping animations
	# Animation in the air
	#============================================================
	#+----------------------------------------------------
	# Responsible for the crouch jump animation, upwards
	elif Input.is_action_pressed("crouch_idle") and velocity.y < 0:
		animated_sprite_2d.play("jump")
		_crouching_cshape()

	# Responsible for the crouch jump animation, downwards
	elif Input.is_action_pressed("crouch_idle") and velocity.y > 0 and not is_on_floor():
		velocity.x = direction * crouch_speed
		animated_sprite_2d.play("crouch_falling")
		_crouching_cshape()

	
		
	
	#+----------------------------------------------------

	#+----------------------------------------------------
	# Normal jump animation
	elif not is_on_floor() and velocity.y < 0 :
		_standing_cshape()
		animated_sprite_2d.play("jump")
		

	# Normal fall animation
	elif not is_on_floor() and velocity.y > 0 :
		_standing_cshape()
		animated_sprite_2d.play("fall")

	# Move the character
	move_and_slide()
	#============================================================


	
	
func _on_wall_slide_timer_timeout():
	# This function is called when the timer completes
	can_wall_slide = true  # Allow wall sliding
	
func _attack():
	pass
	#animated_sprite_2d.play("attack")
	
func _jump():
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = jump_force 

func _crouching_cshape():
	collision_shape_2d.shape = crouching_cshape
	
	collision_shape_2d.position.x = -39
	collision_shape_2d.position.y = -14
		
func _standing_cshape():
	collision_shape_2d.shape = standing_cshape
	collision_shape_2d.position.x = -39
	collision_shape_2d.position.y = -20
	
	

	




	

func _wall_sliding():
	# Wall sliding logic
	if is_on_wall_only():
		if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			if wall_slide_timer.is_stopped():
				wall_slide_timer.start()  # Start the timer if not already running
		else:
			wall_slide_timer.stop()  # Stop the timer if the player is not pressing left/right
			is_wall_sliding = false
	else:
		wall_slide_timer.stop()  # Stop the timer if the player is not on the wall
		is_wall_sliding = false
		can_wall_slide = false
	

	
		
