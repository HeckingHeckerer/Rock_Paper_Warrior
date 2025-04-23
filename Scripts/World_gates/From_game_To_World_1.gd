extends Area2D



var entered_door = false

func _on_body_entered(body) -> void:
	if body.has_method("player"):
		entered_door = true
		print("Door Entered")

func _on_body_exited(body) -> void:
	if body.has_method("player"):
		entered_door = false
		print("Door Exit")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and entered_door:
		call_deferred("_change_scene")
		
func _change_scene():
		get_tree().change_scene_to_file("res://Rock_Paper_Warrior/Scene/worlds/wake_up_world.tscn")
