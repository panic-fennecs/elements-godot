extends Node2D

const REPEL_DISTANCE = 30
const GRID_SIZE_X = 30
const GRID_SIZE_Y = 30
const GRID_SIZE = Vector2(GRID_SIZE_X, GRID_SIZE_Y)
var CELL_SIZE = $"/root/Main/Level".WORLD_SIZE / GRID_SIZE

var p = preload("res://src/level/Fluid.tscn")

var fluids = []

func _add_fluid(pos):
	var fluid = p.instance()
	fluid.position = pos
	fluids.append(fluid)
	add_child(fluid)

func _ready():
	for x in range(10):
		for y in range(10):
			_add_fluid(Vector2(x*30+200, y*30+200))

func _physics_process(delta):
	for f in fluids:
		f.sub_physics_process(delta)

	var grid = []
	for x in range(GRID_SIZE_X):
		for y in range(GRID_SIZE_Y):
			grid.append([])
	
	for f in fluids:
		var p = (f.position / CELL_SIZE).floor()
		grid[p.x + p.y * GRID_SIZE.x].append(f)
	
	var dx = int(REPEL_DISTANCE / CELL_SIZE.x) + 1
	var dy = int(REPEL_DISTANCE / CELL_SIZE.y) + 1

	for i in range(len(grid)):
		for f1 in grid[i]:
			if f1.is_solid(): continue
			var x1 = i % GRID_SIZE_X
			var y1 = i / GRID_SIZE_X
			var x2min = max(0, x1 - dx)
			var x2max = min(GRID_SIZE_X, x1 + dx + 1)
			var y2min = max(0, y1 - dy)
			var y2max = min(GRID_SIZE_X, y1 + dy + 1)
			for x2 in range(x2min, x2max):
				for y2 in range(y2min, y2max):
					for f2 in grid[x2 + y2 * GRID_SIZE_X]:
						if f1 == f2: continue
						var v = f1.position - f2.position
						if v.length_squared() <= REPEL_DISTANCE*REPEL_DISTANCE:
							f1.apply_force(v)
