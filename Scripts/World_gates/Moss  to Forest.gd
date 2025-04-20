extends Node2D








func _on_transition_body_entered(body):
	if body is Player:
		#transition_scene.play("fade_in")
		#await get_tree().create_timer(0.6).timeout
		get_tree().change_scene_to_file("res://Rock_Paper_Warrior/Scene/worlds/world_1.tscn")


func _on_damage_objects_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		if player.can_take_damage and not player.dead:
			player.take_damage(50)
		
