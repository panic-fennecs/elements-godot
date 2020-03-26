extends Node2D

const REPEL_DISTANCE = 10

var p = preload("res://src/level/Element.tscn")

var elements = []

func _add_elem(pos):
	var element = p.instance()
	element.position = pos
	elements.append(element)
	add_child(element)

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(10):
		for y in range(10):
			_add_elem(Vector2(x+200, y+200))

func _physics_process(delta):
	for e1 in elements:
		for e2 in elements:
			var v = e1.position - e2.position
			if v.length() <= REPEL_DISTANCE:
				e1.apply_force(v / 1000)
				e2.apply_force(-v / 1000)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
