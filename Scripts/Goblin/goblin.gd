extends CharacterBody2D
class_name Goblin_enemy

@onready var goblin_animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var gob_deal_dmg: Area2D = $Gob_deal_dmg

# Stats
var health = 50
var health_max = 50
var health_min = 0
var dead = false
var damage_to_deal = 20
var coins = randi_range(30, 90)

# State Machine
var main_sm : LimboHSM




func _ready():
	# Initialize state machine
	initiate_state_machine()
	goblin_animated.animation_finished.connect(_on_animation_finished)
	
func _physics_process(delta: float) -> void:
	flip_sprite(-1)
	Globals.gob_DamageAmount = damage_to_deal
	Globals.gob_DamageZone = $Gob_deal_dmg
	
	if not dead:
		velocity += get_gravity() * delta
		move_and_slide()
	
func flip_sprite(dir):
	if dir > 0:
		goblin_animated.flip_h = false
		gob_deal_dmg.scale.x = 1
	else:
		goblin_animated.flip_h = true
		gob_deal_dmg.scale.x = -1
		
func initiate_state_machine():
	main_sm = LimboHSM.new()
	add_child(main_sm)
	
	# Define states
	var idle_state = LimboState.new().named("idle").call_on_enter(idle_start)
	var take_hit_state = LimboState.new().named("take_hit").call_on_enter(take_hit_start)
	var death_state = LimboState.new().named("death").call_on_enter(death_start)
	var chase_state = LimboState.new().named("chase").call_on_enter(chase_start).call_on_update(chase_update)
	
	# Add states
	main_sm.add_child(idle_state)
	main_sm.add_child(take_hit_state)
	main_sm.add_child(death_state)
	main_sm.add_child(chase_state)
	
	# Set initial state
	main_sm.initial_state = idle_state
	
	# Transitions
	main_sm.add_transition(main_sm.ANYSTATE, death_state, &"to_die")
	main_sm.add_transition(idle_state, take_hit_state, &"to_take_hit")
	main_sm.add_transition(take_hit_state, idle_state, &"state_ended")
	main_sm.add_transition(idle_state, chase_state, &"to_chase")
	main_sm.add_transition(chase_state, idle_state, &"to_roam")
	
	main_sm.initialize(self)
	main_sm.set_active(true)

# State Functions
func idle_start():
	if not dead:
		goblin_animated.play("idle")

func take_hit_start():
	if not dead:
		goblin_animated.play("take_hit")

func death_start():
	dead = true
	goblin_animated.play("death")
	await get_tree().create_timer(2.0).timeout
	queue_free()

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
	if goblin_animated.animation == "take_hit" and not dead:
		main_sm.dispatch(&"state_ended")
		
