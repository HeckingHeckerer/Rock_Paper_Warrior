extends Area2D



var entered = false

func _on_body_entered(body) -> void:
	if body.has_method("player"):
		entered = true
		print("Door Entered")

func _on_body_exited(body) -> void:
	if body.has_method("player"):
		entered = false
		print("Door Exit")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and entered:
		get_tree().change_scene_to_file("res://Rock_Paper_Warrior/Scene/game.tscn")
