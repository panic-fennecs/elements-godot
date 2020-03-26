extends Node2D

var velocity = Vector2(0, 0)
var temperature = 20

func apply_force(f):
	velocity += f

func is_solid():
	return temperature < 0

func is_fluid():
	return !is_solid()

func _physics_process(delta):
	position += velocity
	velocity *= 0.99

	if is_fluid():
		velocity += Vector2(0, 0.2)
	stay_in_view()

func stay_in_view():
	var level_size = get_node("/root/Main/Level").size()
	if position.x < 0:
		position.x = 0
		if velocity.x < 0:
			velocity.x = 0
	if position.y < 0:
		position.y = 0
		if velocity.y < 0:
			velocity.y = 0
	if position.x > level_size.x:
		position.x = level_size.x
		if velocity.x > 0:
			velocity.x = 0
	if position.y > level_size.y:
		position.y = level_size.y
		if velocity.y > 0:
			velocity.y = 0
