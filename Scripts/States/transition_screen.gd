extends CanvasLayer

signal on_transition_finished

# Corrected paths - AnimationPlayer is now child of ColorRect
@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $ColorRect/AnimationPlayer

func _ready():
	if not color_rect:
		push_error("ColorRect node missing!")
		return
	if not animation_player:
		push_error("AnimationPlayer node missing!")
		return
	
	color_rect.visible = false
	# Ensure full screen coverage
	color_rect.size = get_viewport().size
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_viewport_resized():
	color_rect.size = get_viewport().size

func transition():
	color_rect.visible = true
	animation_player.play("fade_to_black")

func _on_animation_finished(anim_name):
	match anim_name:
		"fade_to_black":
			on_transition_finished.emit()
			animation_player.play("fade_to_normal")
		"fade_to_normal":
			color_rect.visible = false
