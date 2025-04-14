extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


const jump_force = -400
const gravity = 1000

func _physics_process(delta: float) -> void:
	
	if is_on_floor() and is_on_wall():
		velocity.y = jump_force
	else:
		velocity += get_gravity() * delta
	
	move(1,10)
	move_and_slide()
	
	
	
func move(dir, speed):
	velocity.x = dir * speed
	handle_animation()
	updateflip(dir)
	
func updateflip(dir):
	if abs(dir) == dir:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
		
func handle_animation():
	if not is_on_floor():
		animated_sprite.play("fall")
	
	
		
	if velocity.x != 0:
		animated_sprite.play("Run")
	else:
		animated_sprite.play("Idle")
