extends Node2D

var velocity = Vector2(0, 0)

func apply_force(f):
	velocity += f

func _physics_process(delta):
	position += velocity
	velocity *= 0.9
