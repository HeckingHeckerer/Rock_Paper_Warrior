extends Node



var level_data = {}  # Will store {level_name: Vector2(position)}

func save_position(level_name: String, position: Vector2):
	level_data[level_name] = position
	# Optional: Save to file for persistence between game sessions
	ResourceSaver.save(level_data, "user://save_data.tres")

func load_position(level_name: String) -> Vector2:
	# Try loading from file first
	if ResourceLoader.exists("user://save_data.tres"):
		level_data = ResourceLoader.load("user://save_data.tres")
	# Return saved position or null if not found
	return level_data.get(level_name)
