extends Node

const scene_wake_up_world = preload("res://Rock_Paper_Warrior/Scene/worlds/wake_up_world.tscn")
const scene_world_1 = preload("res://Rock_Paper_Warrior/Scene/worlds/world_1.tscn")
const scene_goth_vania = preload("res://Rock_Paper_Warrior/Scene/worlds/goth_vania.tscn")
const scene_safe_forest = preload("res://Rock_Paper_Warrior/Scene/worlds/safe_forest.tscn")
signal on_trigger_player_spawn

var spawn_door_tag
var transition_screen: TransitionScreen

func _ready():
	# Get reference to existing TransitionScreen or create one
	transition_screen = get_tree().get_first_node_in_group("transition_screen")
	if not transition_screen:
		transition_screen = preload("res://Rock_Paper_Warrior/Scene/Resource/Transition_screen.tscn").instantiate()
		get_tree().root.add_child(transition_screen)
		transition_screen.add_to_group("transition_screen")

func go_to_level(level_tag, destination_tag):
	# Start music transition
	MusicManager.play_music(level_tag)
	
	var scene_to_load

	match level_tag:
		"wake_up_world":
			scene_to_load = scene_wake_up_world
		"world_1":
			scene_to_load = scene_world_1
		"goth_vania":
			scene_to_load = scene_goth_vania
		"safe_forest":
			scene_to_load = scene_safe_forest
		_:
			scene_to_load = null
		
	if scene_to_load:
		
		
		spawn_door_tag = destination_tag
		await get_tree().create_timer(0.2).timeout
		_change_scene_safely(scene_to_load)

func _change_scene_safely(scene):
	get_tree().change_scene_to_packed(scene)

func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
