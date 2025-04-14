extends CharacterBody2D

@onready var main_character: CharacterBody2D = $"."

var player_in_area : bool = false


func ready():
	pass
	
func _process(delta):
	if player_in_area:
		if Input.is_action_just_pressed("interact"):
			run_dialogue("Wizard_Merchant/Wizard_Merchant")
			print("player TALKED")
func run_dialogue(dialogue_string):
	Dialogic.start(dialogue_string)
	



func _on_chatdetect_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		print("player Entered")


func _on_chatdetect_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
			player_in_area = false	
			print("player exxit")
