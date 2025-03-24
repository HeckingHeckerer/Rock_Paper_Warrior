extends State



class_name Enemy_idle

@export var Boss: CharacterBody2D
@export var movespeed := 150.0

var movedirection : Vector2
var wandertime : float

func rando_wander():
	movedirection = Vector2(randf_range(-1,1),0).normalized()
	wandertime = randf_range(1,2)
	
func enter():
	rando_wander()
	
func update(delta):
	if wandertime > 0:
		wandertime -= delta
	
	else:
		rando_wander()

func _physics_process(delta: float):
	if Boss:
		Boss.velocity = movedirection * movespeed
