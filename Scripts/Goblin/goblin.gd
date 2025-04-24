extends CharacterBody2D
class_name Goblin_enemy


@onready var goblin_animated: AnimatedSprite2D = $AnimatedSprite2D




var attack_range = 50.0  # Distance to initiate attack
var attack_cooldown = 1.5  # Time between attacks
var can_attack = true
var is_attacking = false
@onready var gob_deal_dmg: Area2D = $Gob_deal_dmg

# Stats
var health = 50
var health_max = 50
var health_min = 0
var dead = false
var damage_to_deal = 20
var coins = randi_range(30, 90)
var jump_force = -350

# State Machine
var main_sm : LimboHSM

# Raycasts
@onready var detect_ray_cast: RayCast2D = $DetectRayCast
@onready var attack_ray_cast: RayCast2D = $AttackRayCast

@export var move_speed: float = 100
@export var chase_speed: int = 150
@export var acceleration: int = 200
@onready var timer: Timer = $Timer

# Movement
@export var move_speed: float = 165
@export var move_tolerance: float = 10
var current_direction: int = 1

func _ready():
	# Initialize state machine
	initiate_state_machine()
	goblin_animated.animation_finished.connect(_on_animation_finished)
	
<<<<<<< HEAD
	# Set patrol bounds relative to starting position
	left_bounds = self.position + Vector2(-125, 0)
	right_bounds = self.position + Vector2(125, 0)
	
	# Set initial target position
	choose_new_target_position()
	
	 # Connect signals
	if not goblin_animated.animation_finished.is_connected(_on_animation_finished):
		goblin_animated.animation_finished.connect(_on_animation_finished)
	
	


	
	# Initialize damage area
	

=======
>>>>>>> parent of d3cf17c (iyurewrstyhdftyukujrhtgrfe)
func _physics_process(delta: float) -> void:
	
	Globals.gob_DamageAmount = damage_to_deal
	Globals.gob_DamageZone = $Gob_deal_dmg
	
	if not dead:
		velocity += get_gravity() * delta
		move_and_slide()
		
# Movement function called by BTAction
func move(dir: int, speed: float):
	if dead: return
	
	current_direction = dir
	flip_sprite(dir)
	
	if speed > 0:
		main_sm.dispatch(&"to_move")
		velocity.x = dir * speed
	else:
		main_sm.dispatch(&"to_idle")
		velocity.x = 0
	
func flip_sprite(dir):
	if dir > 0:
		goblin_animated.flip_h = false
<<<<<<< HEAD
		
	else:
		goblin_animated.flip_h = true
		
		

func choose_new_target_position():
	# Choose a random position within bounds
	target_position = Vector2(
		randf_range(left_bounds.x, right_bounds.x),
		position.y
	)

=======
		gob_deal_dmg.scale.x = 1
	else:
		goblin_animated.flip_h = true
		gob_deal_dmg.scale.x = -1
		
>>>>>>> parent of d3cf17c (iyurewrstyhdftyukujrhtgrfe)
func initiate_state_machine():
	main_sm = LimboHSM.new()
	add_child(main_sm)
	
	# Define states
	var move_state = LimboState.new().named("move").call_on_enter(move_start).call_on_update(move_update)
	var take_hit_state = LimboState.new().named("take_hit").call_on_enter(take_hit_start)
	var death_state = LimboState.new().named("death").call_on_enter(death_start)
<<<<<<< HEAD

	var attack_state = LimboState.new().named("attack").call_on_enter(attack_start)
	var chase_state = LimboState.new().named("chase").call_on_enter(chase_start).call_on_update(chase_update)
	
	# Add states
	main_sm.add_child(idle_state)
	main_sm.add_child(move_state)
	main_sm.add_child(take_hit_state)
	main_sm.add_child(death_state)
	
	main_sm.add_child(attack_state)
	main_sm.add_child(chase_state)
	
	# Set initial state
	
	# Transitions
	main_sm.add_transition(main_sm.ANYSTATE, death_state, &"to_die")
	main_sm.add_transition(main_sm.ANYSTATE, take_hit_state, &"to_take_hit")
	main_sm.add_transition(idle_state, take_hit_state, &"to_take_hit")
	main_sm.add_transition(take_hit_state, idle_state, &"state_ended")
	main_sm.add_transition(idle_state, move_state, &"to_roam")
	
	main_sm.add_transition(move_state, idle_state, &"to_idle")
	
	
	main_sm.add_transition(attack_state, move_state, &"to_roam")
	
	main_sm.add_transition(idle_state, chase_state, &"to_chase")
	main_sm.add_transition(chase_state, idle_state, &"to_roam")
	main_sm.add_transition(idle_state, move_state, &"to_move")
	main_sm.add_transition(move_state, idle_state, &"to_idle")
	
	main_sm.initialize(self)
	main_sm.set_active(true)

# State Functions
func idle_start():
	print("IDLE STATE GOBLIN")
	if not dead:
		goblin_animated.play("idle")

func move_start():
	print("MOVE STATE GOBLIN")
	if not dead:
		goblin_animated.play("run")

func move_update(delta):
	if dead:
		return
	
	# Calculate direction to target
	var dir = sign(target_position.x - position.x)
	flip_sprite(dir)
	
	# Move toward target
	velocity.x = move_toward(velocity.x, dir * move_speed, acceleration * delta)
	
	# Check if reached target or hit bounds
	if abs(target_position.x - position.x) <= move_tolerance:
		main_sm.dispatch(&"to_idle")
	elif (dir > 0 and position.x >= right_bounds.x) or (dir < 0 and position.x <= left_bounds.x):
		# Hit bounds, choose new target in opposite direction
		choose_new_target_position()



func move_update(delta: float):
	pass  # Movement is handled in physics_process via move() function

func take_hit_start():
	print("TAKE HIT GOBLIN")
	if not dead:
		goblin_animated.play("take_hit")

func death_start():
	print("TAKE HIT GOBLIN")
	dead = true
	
	
	
	
	goblin_animated.play("death")
	await get_tree().create_timer(2.0).timeout
	queue_free()

func attack_start():
	if dead or not can_attack:
		return
		
	is_attacking = true
	can_attack = false
	velocity.x = 0  # Stop moving during attack
	goblin_animated.play("attack")
	
	# Enable damage area during attack animation
	
	

	
	# Check if we should continue chasing or return to roaming
	var player = Globals.playerBody
	if player and is_instance_valid(player) and detect_ray_cast.is_colliding() and detect_ray_cast.get_collider() == player:
		main_sm.dispatch(&"attack_ended")
	else:
		main_sm.dispatch(&"to_roam")

func _on_attack_animation_finished():
	if goblin_animated.animation == "attack":
		is_attacking = false



# Damage Handling
func _on_gob_hitbox_area_entered(area: Area2D) -> void:
	if area == Globals.playerDamageZone and not dead:
		take_damage(Globals.playerDamageAmount)

func take_damage(damage):
	if dead: return
	
	health -= damage
	health = max(health, 0)
	
	if health <= 0:
		
		
		main_sm.dispatch(&"to_die")
	else:
		main_sm.dispatch(&"to_take_hit")
	
	print(str(self), " current health: ", health)

func chase_start():
	pass

func chase_update(delta: float):
	pass
# Physics


# Animation Callback - This is where we handle the transition
func _on_animation_finished():
	match goblin_animated.animation:
		"take_hit":
			if not dead:
				main_sm.dispatch(&"state_ended")
		"attack":
			_on_attack_animation_finished()
		#"death":
		 # Ensure collisions stay disabled
	
		



			

func _on_damage_body_entered(body: Node2D) -> void:
	if dead:  # Early return if dead
		return
		
	if body is Player:
		var player = body as Player
		if player.can_take_damage and not player.dead:
		
			player.take_damage(20)
	if goblin_animated.animation == "take_hit" and not dead:
		main_sm.dispatch(&"state_ended")
		
