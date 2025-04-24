extends CharacterBody2D

## Movement speed in pixels per second
@export var speed: float = 60.0
## Minimum idle time between movements (seconds)
@export var min_idle_time: float = 1.0
## Maximum idle time between movements (seconds)
@export var max_idle_time: float = 3.0
## Maximum horizontal movement distance
@export var max_move_distance: float = 160.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var start_position: Vector2 = global_position

var _move_direction: int = 1
var _idle_timer: float = 0.0
var _is_moving: bool = false
var _target_x: float

func _ready():
	_start_idle()
	# Random initial direction
	_move_direction = 1 if randf() > 0.5 else -1
	animated_sprite.flip_h = _move_direction < 0

func _physics_process(delta):
	if _is_moving:
		_handle_movement(delta)
	else:
		_update_idle_timer(delta)

func _start_idle():
	_is_moving = false
	animated_sprite.play("idle")
	_idle_timer = randf_range(min_idle_time, max_idle_time)
	velocity = Vector2.ZERO

func _start_moving():
	_is_moving = true
	animated_sprite.play("walk")
	# Set random target position within bounds
	_target_x = start_position.x + randf_range(-max_move_distance, max_move_distance)
	_move_direction = sign(_target_x - global_position.x)
	animated_sprite.flip_h = _move_direction < 0

func _update_idle_timer(delta):
	_idle_timer -= delta
	if _idle_timer <= 0:
		_start_moving()

func _handle_movement(delta):
	# Simple platformer movement with gravity
	velocity.x = _move_direction * speed
	velocity.y += 300 * delta  # Apply gravity
	
	# Check if reached target position or hit wall
	if (abs(global_position.x - _target_x) < 5.0 or 
		is_on_wall() or 
		not is_on_floor()):
		_start_idle()
	
	move_and_slide()
