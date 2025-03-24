extends CharacterBody2D


class_name Blade
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
func _physics_process(delta: float):
	move_and_slide()
	
	if velocity.length() > 0:
		animated_sprite_2d.play("Run")
		
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true
		
