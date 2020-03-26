extends Node2D

const SOLID_GRID_SIZE_X = 128
const SOLID_GRID_SIZE_Y = 64
const SOLID_GRID_SIZE = Vector2(SOLID_GRID_SIZE_X, SOLID_GRID_SIZE_Y)
onready var SOLID_CELL_SIZE = $"/root/Main/Level".WORLD_SIZE / SOLID_GRID_SIZE

var solid_grid = []

func _ready():
	for x in range(SOLID_GRID_SIZE_X):
		for y in range(SOLID_GRID_SIZE_Y):
			solid_grid.append(false)
	
	for x in range(SOLID_GRID_SIZE_X):
		for y in range(10):
			solid_grid[x + (SOLID_GRID_SIZE_Y-y-1) * SOLID_GRID_SIZE_X] = true
