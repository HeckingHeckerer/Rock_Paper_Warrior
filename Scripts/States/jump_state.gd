extends PlayerState  # Now it correctly finds PlayerState

class_name Jump  # Optionally, give it a class name

func enter_state(player_node):
	super(player_node)
	player.velocity.y = player.jump_force
	
func exit_state():
	pass
	
func handle_input(_delta):
	pass
