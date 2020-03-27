extends Node2D

var velocity = Vector2(0, 0)
var temperature = 20
onready var type = $"/root/Main/Level/FluidManager".FluidType.Water

func apply_force(f):
	var pressure = 1 / max(0.01, f.length())
	velocity += f.normalized() * 10 * pressure


func apply_pull_force(f):
	var pressure = 1 #/ max(0.01, f.length())
	velocity -= f.normalized() * 1 * pressure

func sub_physics_process(delta):
	position += velocity
	velocity *= 0.99

	velocity += Vector2(0, 0.2)
	stay_in_view()

func stay_in_view():
	var level_size = $"/root/Main/Level".WORLD_SIZE
	if position.x < 0:
		position.x = 0
		if velocity.x < 0:
			velocity.x = 1
	if position.y < 0:
		position.y = 0
		if velocity.y < 0:
			velocity.y = 1
	if position.x >= level_size.x:
		position.x = level_size.x-1
		if velocity.x > 0:
			velocity.x = -1
	if position.y >= level_size.y:
		position.y = level_size.y-1
		if velocity.y > 0:
			velocity.y = -1
	# choosing 1 and -1 as fallbacks makes the elements get some distance from the world border
