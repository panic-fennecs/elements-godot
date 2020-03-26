extends Node2D

const REPEL_DISTANCE = 5

var p = preload("res://src/level/Element.tscn")

var elements = []

func size():
	return get_viewport().size

func _add_fluid(pos):
	var element = p.instance()
	element.position = pos
	elements.append(element)
	add_child(element)

func _add_solid(pos):
	var element = p.instance()
	element.position = pos
	elements.append(element)
	element.temperature = -20
	add_child(element)

# Called when the node enters the scene tree for the first time.
func _ready():
	return
	for x in range(int(size().x)/10):
		for y in range(10):
			_add_solid(Vector2(x*10, 900 + y*10))
	for x in range(10):
		for y in range(10):
			_add_fluid(Vector2(x+200, y+200))

func _physics_process(delta):
	for e1 in elements:
		for e2 in elements:
			var v = e1.position - e2.position
			if v.length() <= REPEL_DISTANCE:
				e1.apply_force(v / 100)
				e2.apply_force(-v / 100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
