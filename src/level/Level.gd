extends Node2D

const REPEL_DISTANCE = 40
const GRID_SIZE_X = 30
const GRID_SIZE_Y = 30
const GRID_SIZE = Vector2(GRID_SIZE_X, GRID_SIZE_Y)
const WORLD_SIZE = Vector2(2*956, 1045)

var p = preload("res://src/level/Element.tscn")

var elements = []

func CELL_SIZE():
	return WORLD_SIZE / Vector2(GRID_SIZE_X, GRID_SIZE_Y)

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
	for x in range(int(WORLD_SIZE.x)/10):
		for y in range(10):
			_add_solid(Vector2(x*10, 900 + y*10))
	for x in range(10):
		for y in range(10):
			_add_fluid(Vector2(x*30+200, y*30+200))

func _physics_process(delta):
	for e in elements:
		e.sub_physics_process(delta)
	var grid = []
	for x in range(GRID_SIZE_X):
		for y in range(GRID_SIZE_Y):
			grid.append([])
	
	for e in elements:
		var p = (e.position / CELL_SIZE()).floor()
		grid[p.x + p.y * GRID_SIZE.x].append(e)
	
	var dx = int(REPEL_DISTANCE / CELL_SIZE().x) + 1
	var dy = int(REPEL_DISTANCE / CELL_SIZE().y) + 1

	for i in range(len(grid)):
		for e1 in grid[i]:
			if e1.is_solid(): continue
			var x1 = i % GRID_SIZE_X
			var y1 = i / GRID_SIZE_X
			var x2min = max(0, x1 - dx)
			var x2max = min(GRID_SIZE_X, x1 + dx + 1)
			var y2min = max(0, y1 - dy)
			var y2max = min(GRID_SIZE_X, y1 + dy + 1)
			for x2 in range(x2min, x2max):
				for y2 in range(y2min, y2max):
					for e2 in grid[x2 + y2 * GRID_SIZE_X]:
						if e1 == e2: continue
						var v = e1.position - e2.position
						if v.length_squared() <= REPEL_DISTANCE*REPEL_DISTANCE:
							e1.apply_force(v)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
