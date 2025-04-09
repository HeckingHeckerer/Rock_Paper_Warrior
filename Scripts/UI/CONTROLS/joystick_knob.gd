extends Sprite2D
@onready var parent: Node2D = $".."
 
var pressing = false

@export var maxlength = 45
@export var deadzone = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	maxlength += parent.scale.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if pressing:
		if get_global_mouse_position().distance_to(parent.global_position) <= maxlength:
			global_position = get_global_mouse_position()
		else:
			var angle = parent.global_position.angle_to_point(get_global_mouse_position())
			global_position.x = parent.global_position.x + cos(angle) * maxlength
			global_position.y = parent.global_position.y + sin(angle) * maxlength
	else:
		global_position = lerp(global_position, parent.global_position, delta*20)
		


func _on_button_button_down() -> void:
	pressing = true


func _on_button_button_up() -> void:
	pressing = false
