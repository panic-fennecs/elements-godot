extends Node2D

var velocity = Vector2(0, 0)
var temperature = 20

func apply_force(f):
	if is_fluid():
		var pressure = 1 / max(0.01, f.length())
		velocity += f.normalized() * 10 * pressure

func is_solid():
	return temperature < 0

func is_fluid():
	return !is_solid()

func sub_physics_process(delta):
	if is_solid():
		velocity = Vector2(0, 0)
		return
	position += velocity
	velocity *= 0.99

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
		position.x = level_size.x-1
		if velocity.x > 0:
			velocity.x = 0
	if position.y > level_size.y:
		position.y = level_size.y-1
		if velocity.y > 0:
			velocity.y = 0
