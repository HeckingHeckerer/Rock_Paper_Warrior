extends CharacterBody2D

class_name Goblin_enemy


var player: CharacterBody2D
@onready var goblin_animated: AnimatedSprite2D = $AnimatedSprite2D

var health = 50
var health_max = 50
var health_min = 0
var dead = false
var taking_damage = false
var damage_to_deal = 20
var coins = randi_range(30,90)


func _ready():
	goblin_animated.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
	
func _on_gob_hitbox_area_entered(area: Area2D) -> void:
	if area == Globals.playerDamageZone and not dead:
		var damage = Globals.playerDamageAmount
		take_damage(damage)
		
func take_damage(damage):
	if dead: return
	health -= damage
	taking_damage = true
	
	if health <= 0:
		health = 0
		dead = true
		handle_animation()
		# Wait 2 seconds then delete
		await get_tree().create_timer(2).timeout
		queue_free()
	else:
		handle_animation()
		
	print(str(self), "current health is:" , health)
	
func handle_animation():
	if !dead and !taking_damage:
		goblin_animated.play("idle")
	elif !dead and taking_damage:
		goblin_animated.play("take_hit")
		await get_tree().create_timer(1.0).timeout
		taking_damage = false
	elif dead:
		goblin_animated.play("death")  # or $AnimatedSprite2D.play("death")
		print(str(self), " died. Playing death animation.")

func move():
	pass


func _physics_process(delta: float) -> void:
	Globals.gob_DamageAmount = damage_to_deal
	Globals.gob_DamageZone = $Gob_deal_dmg

	
	if not dead:
		velocity += get_gravity() * delta
		move_and_slide()


func _on_animation_finished():
	match goblin_animated.animation:
		"take_hit":
			if not dead:
				goblin_animated.play("idle")
				taking_damage = false
		"death":
			pass  # Death cleanup if needed
