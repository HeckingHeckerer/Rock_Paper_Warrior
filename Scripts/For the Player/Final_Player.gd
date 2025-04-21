extends CharacterBody2D

class_name Player
@onready var animatedsprite = $AnimatedSprite2D
@export var speed = 165
@export var jump_force = -330
const crouch_speed = 60
const atk_speed = 100
const stone_atk_speed = 20
const sprint_speed = 300
const wall_slide_gravity = 100 #A cool mechanic if u set this to 0 it will stick to the wall

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
#@onready var wall_slide_timer: Timer = $"wall slide timer"

var standing_cshape = preload("res://Rock_Paper_Warrior/Resources/mc_standing_idle_cshape.tres")
var crouching_cshape = preload("res://Rock_Paper_Warrior/Resources/mc_crouch_idle_cshape.tres")

var main_sm : LimboHSM
var direction : float 

#attack system:
enum WeaponType { ROCK, PAPER, SCISSORS }
var current_weapon: WeaponType = WeaponType.SCISSORS  # Default weapon
var current_attack : bool

#player health
var health = 100
var health_max = 100 
var health_min = 0
var can_take_damage : bool
var dead: bool

#Player Damage Object feature
var invulnerable_time = 0.8  # Seconds after being hit where player can't take damage
var invulnerable_timer = 0.5
var is_invulnerable = false

@onready var deal_dmg_to_enemy: Area2D = $"Deal dmg to enemy"

func _ready():
	initiate_state_machine()
	current_attack = false
	dead = false
	can_take_damage = true
	animatedsprite.animation_finished.connect(_on_death_animation_finished)
func _physics_process(delta: float) -> void:
	
	
			
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("up") and is_on_floor():
		#velocity.y = jump_force

	
		
	main_sm.update(delta)
		
	Globals.playerDamageZone = deal_dmg_to_enemy
	move_and_slide()

#Combat System

			

	

	
func player():
	pass
	
func flip_sprite(direction):
	if direction == 1:
		animatedsprite.flip_h = false
		deal_dmg_to_enemy.scale.x = 1
		deal_dmg_to_enemy.position.x = -1
	elif direction == -1:
		animatedsprite.flip_h = true
		deal_dmg_to_enemy.scale.x = -1
		deal_dmg_to_enemy.position.x = -77
func _unhandled_input(event: InputEvent):
	
	if !dead:
	
		#============WEAPON HANDKING================
		
		if event.is_action_pressed("Rock"):
			current_weapon = WeaponType.ROCK
			print("Switched to ROCK weapon")
		elif event.is_action_pressed("Paper"):
			current_weapon = WeaponType.PAPER
			print("Switched to PAPER weapon")
		elif event.is_action_pressed("Scissors"):
			current_weapon = WeaponType.SCISSORS
			print("Switched to SCISSORS weapon")
			
		if event.is_action_pressed("crouch_idle"):
			main_sm.dispatch(&"to_crouch")
		elif event.is_action_pressed("crouch_idle") and abs(Input.get_axis("left", "right")) > 0.1:
			main_sm.dispatch(&"to_crouch_walk")
		elif event.is_action_released("crouch_idle"):
			main_sm.dispatch(&"state_ended")
			
		if event.is_action_pressed("up"):
			main_sm.dispatch(&"to_jump")
			
		if event.is_action_pressed("sprint") and abs(Input.get_axis("left", "right")) > 0.1:
			main_sm.dispatch(&"to_sprint")
			
		if event.is_action_pressed("left") or  event.is_action_pressed("right"):
			main_sm.dispatch(&"to_walk")
			
		if event.is_action_pressed("attack"):
			main_sm.dispatch(&"to_attack")
	
	
	
	
	
	
			

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
	var death_state = LimboState.new().named("death").call_on_enter(death_start)
	var take_hit = LimboState.new().named("take_hit").call_on_enter(take_hit_start).call_on_update(take_hit_update)
	
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
	main_sm.add_child(death_state)
	main_sm.add_child(take_hit)
	
	
	main_sm.initial_state = idle_state
	
	#transition state        #from         #to        #signal
	main_sm.add_transition(main_sm.ANYSTATE, idle_state, &"state_ended") #note the state ended will go back to idle
	
	main_sm.add_transition(main_sm.ANYSTATE, attack_state, &"to_attack") #ADD A CROUCH ATTACK LATER ON THE DEVELOPMENT
	
	main_sm.add_transition(main_sm.ANYSTATE, fall_state, &"to_fall")
	
	main_sm.add_transition(idle_state, walk_state, &"to_walk")
	main_sm.add_transition(jump_state, walk_state, &"to_walk")
	
	main_sm.add_transition(idle_state, jump_state, &"to_jump")
	main_sm.add_transition(walk_state, jump_state, &"to_jump")
	main_sm.add_transition(sprint_state, jump_state, &"to_jump")
	main_sm.add_transition(crouch_state, jump_state, &"to_jump")
	
	main_sm.add_transition(idle_state, sprint_state, &"to_sprint")
	main_sm.add_transition(walk_state, sprint_state, &"to_sprint")
	
	#crouching
	main_sm.add_transition(idle_state, crouch_state, &"to_crouch")
	main_sm.add_transition(walk_state, crouch_state, &"to_crouch")
	main_sm.add_transition(sprint_state, crouch_state, &"to_crouch")
	main_sm.add_transition(jump_state, crouch_state, &"to_crouch")
	main_sm.add_transition(attack_state, crouch_state, &"to_crouch")
	main_sm.add_transition(fall_state, crouch_state, &"to_crouch")
	
	#crouch walking 
	main_sm.add_transition(idle_state, crouch_walk_state, &"to_crouch_walk")
	main_sm.add_transition(walk_state, crouch_walk_state, &"to_crouch_walk")
	main_sm.add_transition(sprint_state, crouch_walk_state, &"to_crouch_walk")
	main_sm.add_transition(attack_state, crouch_walk_state, &"to_crouch_walk")
	 # Transition from crouch to crouch walk when moving
	main_sm.add_transition(crouch_state, crouch_walk_state, &"to_crouch_walk")
	
	  # Transition back from crouch walk to crouch when stopping
	main_sm.add_transition(crouch_walk_state, crouch_state, &"to_crouch")
	
	 # Transition from crouch/crouch_walk to other states
	main_sm.add_transition(crouch_state, idle_state, &"state_ended")
	main_sm.add_transition(crouch_walk_state, walk_state, &"state_ended")
	
	main_sm.add_transition(main_sm.ANYSTATE, take_hit, &"to_take_hit")
	main_sm.add_transition(main_sm.ANYSTATE, death_state, &"to_die")
	
	
	
	
	
	
	main_sm.initialize(self)
	main_sm.set_active(true)
	
	
func idle_start():
	animatedsprite.play("Idle")
	_standing_cshape()
	print("entered idle")
func idle_update(delta : float):
	
	velocity.x = 0  # Stop movement in idle
	if Input.get_axis("left", "right"):
		main_sm.dispatch(&"to_walk")
		#===================CHECK FALL=====================
	elif not is_on_floor() and velocity.y > 0 :
		
		main_sm.dispatch(&"to_fall")
	elif  not is_on_floor() and velocity.y < 0: 
		main_sm.dispatch(&"to_jump")
		
	if Input.is_action_pressed("crouch_idle"):
		main_sm.dispatch(&"to_crouch")
	
	
	
		


func walk_start():
	animatedsprite.play("run")
	_standing_cshape()
	print("entered walk")
func walk_update(delta : float):
	
	
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
	
	if Input.is_action_pressed("crouch_idle"):
		if abs(direction) > 0.1:
			main_sm.dispatch(&"to_crouch_walk")
		else:
			main_sm.dispatch(&"to_crouch")
	

func jump_start():
	animatedsprite.play("jump")
	_standing_cshape()
	print("Enter_JU8mp")
	
	if is_on_floor():
		velocity.y = jump_force
	
	
func jump_update(delta : float):
	
	#JUMP SPRINT TIMER NOT EMPLEMENTED, YOU NEED ATLEAST 1.5 SECONDS IN ORDER TO DO SRPINT JUMP
	
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
		
	if Input.is_action_pressed("crouch_idle"):
		main_sm.dispatch(&"to_crouch")
	
	
	 
func fall_start():
	
	#if Input.is_action_pressed("crouch_idle") and velocity.y > 0:
		#animatedsprite.play("crouch_falling")
		
	
	animatedsprite.play("fall")
		

	_standing_cshape()
	print("fall state")
	
	
func fall_update(delta : float):
	

	direction = Input.get_axis("left", "right")
	velocity.x = direction * speed
	flip_sprite(direction)
	
	if is_on_floor():
		main_sm.dispatch(&"state_ended")
	
	
	
func attack_start():
	current_attack = true 
	var random_chance = randf()
	var attack_weapon := current_weapon #this insures that the animation and damage stays locked in
	toggle_attack_cols()
	set_damage(attack_weapon)
	#DIFFERENT WEAPON TYPE ANIMATIONS
	match attack_weapon:
		WeaponType.ROCK:
			if random_chance < 0.5:
				animatedsprite.play("bash_attack_1")
				print("ROCK1")
			else:
				animatedsprite.play("bash_attack_2")
				print("ROCK2")
		WeaponType.PAPER:
			if random_chance < 0.5:
				animatedsprite.play("attack")
				print("PAPER1")
			else:
				animatedsprite.play("attack")
				print("PAPER2")
		WeaponType.SCISSORS:
			if random_chance < 0.5:
				animatedsprite.play("attack")
				print("SCIRROS1")
			else:
				animatedsprite.play("attack_2")
				print("SCIRROS2")
	# 50% chance for each animation
	
	
	if is_on_floor() and Input.is_action_pressed("crouch_idle"):
		animatedsprite.play("crouch_attack")
	
		
	_standing_cshape()
	print("entered attack")
	
	if animatedsprite.animation_finished.is_connected(_on_attack_finished):
		animatedsprite.animation_finished.disconnect(_on_attack_finished)
		
	animatedsprite.animation_finished.connect(_on_attack_finished)

func attack_update(delta : float):
	
	
	direction = Input.get_axis("left", "right")
	
	flip_sprite(direction)
	if animatedsprite.animation == "attack" or animatedsprite.animation == "attack_2" :
		velocity.x = direction * atk_speed
	elif  animatedsprite.animation == "bash_attack_1" or animatedsprite.animation == "bash_attack_2":
		velocity.x = direction * stone_atk_speed
		
		
	else:
		velocity.x = direction * crouch_speed
		_crouching_cshape()
	#if animatedsprite.animation != "attack" :
		#main_sm.dispatch(&"state_ended")
	
	
	#if animatedsprite.animation != "attack" and animatedsprite.animation != "attack_2" and animatedsprite.animation != "crouch_attack" :
		#current_attack = false 
		#main_sm.dispatch(&"state_ended")
	
		
func _on_attack_finished():
	if current_attack:
		current_attack = false
		match animatedsprite.animation:
			"attack":
				print("Attack animation finished, returning to idle")
				main_sm.dispatch(&"state_ended")
			"attack_2":
				print("Attack_TWO animation finished, returning to idle")
				main_sm.dispatch(&"state_ended")
			"bash_attack_1":
				print("Rock1 animation finished, returning to idle")
				main_sm.dispatch(&"state_ended")
			"bash_attack_2":
				print("Rock2 animation finished, returning to idle")
				main_sm.dispatch(&"state_ended")
			"paper_attack_1":
				print("paper_attack_1 animation finished, returning to idle")
				main_sm.dispatch(&"state_ended")
			"paper_attack_2":
				print("paper_attack_1 animation finished, returning to idle")
				main_sm.dispatch(&"state_ended")
			"crouch_attack":
				print("Crouch attack animation finished, returning to crouch")
				
				main_sm.dispatch(&"to_crouch")
		
	
func toggle_attack_cols():
	var damaga_coll_stand = deal_dmg_to_enemy.get_node("standing")
	var damaga_coll_crouch = deal_dmg_to_enemy.get_node("crouching")
	var wait_time : float
	var active_collider : CollisionShape2D
	
	
	
	if current_attack:
		wait_time = 0.3

	# Determine which one to enable based on current input
	if is_on_floor() and Input.is_action_pressed("crouch_idle"):
		damaga_coll_crouch.disabled = false
		active_collider = damaga_coll_crouch
	else:
		damaga_coll_stand.disabled = false
		active_collider = damaga_coll_stand
	
	await get_tree().create_timer(wait_time).timeout

	# Disable the one we previously activated
	active_collider.disabled = true
	
func set_damage(weapon: WeaponType):
	var current_damage : int
	match current_weapon:
		WeaponType.ROCK:
			current_damage = 20
		WeaponType.PAPER:
			current_damage = 8
		WeaponType.SCISSORS:
			current_damage = 10
			
	Globals.playerDamageAmount = current_damage
		
func crouch_start():
	animatedsprite.play("crouch_idle")
	_crouching_cshape()
	velocity.x = 0
	print("entered crouch")
	
func crouch_update(delta : float):
	
	direction = Input.get_axis("left", "right")
	flip_sprite(direction)
	
	 # Check if player is trying to move while crouched
	if abs(direction) > 0.1:
		main_sm.dispatch(&"to_crouch_walk")
	
	# Check if player released crouch
	if not Input.is_action_pressed("crouch_idle"):
		main_sm.dispatch(&"state_ended")
	
	if is_on_floor() and Input.is_action_pressed("up"):
		main_sm.dispatch(&"to_jump")
	
	
	
	
	
func crouch_walk_start():
	animatedsprite.play("crouch_walk")
	_crouching_cshape()
	print("entered crouch walk")
func crouch_walk_update(delta : float):
	direction = Input.get_axis("left", "right")
	flip_sprite(direction)
	velocity.x = direction * crouch_speed
	
	 # If stopped moving, go back to crouch idle
	if abs(direction) < 0.1:
		main_sm.dispatch(&"to_crouch")
	
	 # If released crouch, go to appropriate state
	if not Input.is_action_pressed("crouch_idle"):
		if abs(direction) > 0.1:
			main_sm.dispatch(&"to_walk")
		else:
			main_sm.dispatch(&"state_ended")
			
	if not is_on_floor():
		animatedsprite.play("crouch_idle")
	else:
		animatedsprite.play("crouch_walk")
	
func sprint_start():
	animatedsprite.play("sprint")
	print("ente3red sprint")
func sprint_update(delta : float):
	
	_standing_cshape()
	direction = Input.get_axis("left", "right")
	velocity.x = direction * sprint_speed
	flip_sprite(direction)
	
	if velocity.x == 0:
		main_sm.dispatch(&"state_ended")
		
	if Input.is_action_just_released("sprint"):
		main_sm.dispatch(&"state_ended")
	elif  not is_on_floor() and velocity.y < 0: 
		main_sm.dispatch(&"to_jump")
	
	if Input.is_action_pressed("crouch_idle"):
		if abs(direction) > 0.1:
			main_sm.dispatch(&"to_crouch_walk")
		else:
			main_sm.dispatch(&"to_crouch")
			
func wall_slide_start():
	pass
func wall_slide_update(delta : float):
	pass


func take_hit_start():
	animatedsprite.play("take_hit")
	# Apply knockback
	velocity.y = -150  # Small knockback upwards
	velocity.x = -100 * direction  # Knockback opposite facing direction
	print("Entered take_hit state")
	
func take_hit_update(delta):
	# Count down invulnerability timer
	invulnerable_timer -= delta
	if invulnerable_timer <= 0:
		is_invulnerable = false
		main_sm.dispatch(&"state_ended")  # Return to previous state

	
func take_damage(damage):
	if is_invulnerable or dead:
		return
		
	health -= damage
	print("Player took ", damage, " damage. Health: ", health)
	
	# Invulnerability frames
	is_invulnerable = true
	invulnerable_timer = invulnerable_time
	
	# Dispatch to appropriate state
	if health > 0:
		main_sm.dispatch(&"to_take_hit")
	else:
		main_sm.dispatch(&"to_die")

func check_hitbox():
	if is_invulnerable or dead:
		return
		
	var hitbox_areas = $PlayerHitbox.get_overlapping_areas()
	if hitbox_areas:
		take_damage(50)  # 50 damage per hit
		
func death_start():
	dead = true
	can_take_damage = false
	animatedsprite.play("death")
	velocity = Vector2.ZERO  # Stop all movement
	print("Entered death state")
	

	
func _on_death_animation_finished():
	if animatedsprite.animation == "death":
		# Reload current scene after death animation
		await get_tree().create_timer(0.5).timeout
		get_tree().reload_current_scene()
