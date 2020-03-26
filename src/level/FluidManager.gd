extends Node2D

const REPEL_DISTANCE = 40
const FLUID_GRID_SIZE_X = 20
const FLUID_GRID_SIZE_Y = 20
const FLUID_GRID_SIZE = Vector2(FLUID_GRID_SIZE_X, FLUID_GRID_SIZE_Y)
onready var FLUID_CELL_SIZE = $"/root/Main/Level".WORLD_SIZE / FLUID_GRID_SIZE

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

func create_grid():
	var grid = []
	for x in range(FLUID_GRID_SIZE_X):
		for y in range(FLUID_GRID_SIZE_Y):
			grid.append([])
	
	for f in fluids:
		var p = (f.position / FLUID_CELL_SIZE).floor()
		grid[p.x + p.y * FLUID_GRID_SIZE.x].append(f)
	return grid

func _physics_process(delta):
	for f in fluids:
		f.sub_physics_process(delta)

	var grid = create_grid()
	
	var dx = int(REPEL_DISTANCE / FLUID_CELL_SIZE.x) + 1
	var dy = int(REPEL_DISTANCE / FLUID_CELL_SIZE.y) + 1

	for i in range(len(grid)):
		for f1 in grid[i]:
			var x1 = i % FLUID_GRID_SIZE_X
			var y1 = i / FLUID_GRID_SIZE_X
			var x2min = max(0, x1 - dx)
			var x2max = min(FLUID_GRID_SIZE_X, x1 + dx + 1)
			var y2min = max(0, y1 - dy)
			var y2max = min(FLUID_GRID_SIZE_X, y1 + dy + 1)
			for x2 in range(x2min, x2max):
				for y2 in range(y2min, y2max):
					for f2 in grid[x2 + y2 * FLUID_GRID_SIZE_X]:
						if f1 == f2: continue
						var v = f1.position - f2.position
						if v.length_squared() <= REPEL_DISTANCE*REPEL_DISTANCE:
							f1.apply_force(v)
