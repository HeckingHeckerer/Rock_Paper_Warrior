#player_idle.gd(idle state)
extends PlayerState

class_name IdleState



func enter_state(_player):
	super.enter_state(_player)
	player.velocity = Vector2.ZERO  # Stop movement when idling
	
	if player.has_node("AnimatedSprite2D"):
		player.get_node("AnimatedSprite2D").play("Idle")

func handle_input(delta):
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		player.change_state("RunState")
	elif Input.is_action_just_pressed("up"):
		player.change_state("JumpState")
