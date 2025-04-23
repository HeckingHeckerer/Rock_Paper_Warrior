extends CharacterBody2D

@export var FIRE_BALL_SPEED = 150

var dir: float
var spawnPos: Vector2
@export var speed: float = 300
@export var damage: int = 8  # Matches your paper damage
@export var lifetime: float = 2.0  # Automatically delete after this time

var direction: float = 1  # Will be set when spawned
var traveled_distance: float = 0
var max_distance: float = 500  # Max distance before disappearing


func _ready() -> void:
	# Set initial position and rotation
	global_position = spawnPos
	if direction < 0:
		scale.x = -1  # Flip if moving left
	
	# Delete after lifetime expires
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	# Movement
	var movement = Vector2.RIGHT * speed * delta * direction
	position += movement
	traveled_distance += abs(movement.x)
	
	# Delete if traveled too far
	if traveled_distance > max_distance:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Handle hitting enemies
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()  # Delete after hitting something

func _on_area_entered(area: Area2D) -> void:
	# Handle hitting enemy hitboxes
	if area.is_in_group("enemy_hitbox"):
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(damage)
		queue_free()
