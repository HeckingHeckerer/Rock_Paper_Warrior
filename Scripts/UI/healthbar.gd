extends ProgressBar

@onready var timer: Timer = $Timer
@onready var damagebar: ProgressBar = $Damagebar
var player: Player  # Will reference your player node

func _ready() -> void:
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		# Initialize the progress bar values
		max_value = player.health_max
		value = player.health
		damagebar.max_value = player.health_max
		damagebar.value = player.health
		
		# Connect to player's health changed signal (see step 2)
		player.health_changed.connect(update_health)
	else:
		push_error("Player node not found!")

func update_health(new_health: int):
	value = new_health
	# Optional: Add damage delay effect
	timer.start(0.3)  # Delay before damagebar updates

func _on_timer_timeout():
	damagebar.value = value
