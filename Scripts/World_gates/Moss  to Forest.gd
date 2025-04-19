extends Node2D




func _on_transition_body_entered(body: Node2D) -> void:
	if body is Player:
		get_tree().change_scene_to_file("res://Rock_Paper_Warrior/Scene/worlds/world_1.tscn")


func _on_transition_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
