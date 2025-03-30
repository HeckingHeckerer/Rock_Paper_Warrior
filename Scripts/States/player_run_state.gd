# Run State (player_run_state.gd)
extends PlayerState

class_name RunState

func enter_state(_player):
	super.enter_state(_player)
	player.animated_sprite_2d.play("run")

func handle_input(delta):
	var direction = Input.get_axis("left", "right")
	if direction == 0:
		player.change_state("IdleState")
	elif Input.is_action_just_pressed("up"):
		player.change_state("JumpState")
	
	# Apply movement speed
	player.velocity.x = direction * player.speed
	player.move_and_slide()
