extends State

class_name PLayer_idle
@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"
@export var sprite : AnimatedSprite2D


func Enter():
	sprite.play("Idle")
	print("played idle")
	pass
	
func Update(_delta:float):
	if(Input.get_vector("left", "right", "none", "none")):
		pass
		
	if(Input.is_action_just_pressed("attack")):
		pass
		

	
func Exit():
	pass
	
