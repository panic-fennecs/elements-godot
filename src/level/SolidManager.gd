extends Node2D

const SOLID_GRID_SIZE_X = 16*8
const SOLID_GRID_SIZE_Y = 9*8
const SOLID_GRID_SIZE = Vector2(SOLID_GRID_SIZE_X, SOLID_GRID_SIZE_Y)
onready var SOLID_CELL_SIZE = $"/root/Main/Level".WORLD_SIZE / SOLID_GRID_SIZE

enum SolidType {
	None,
	Ice,
	Obsidian,
	Bedrock
}

var solid_grid = []

func _ready():
	for x in range(SOLID_GRID_SIZE_X):
		for y in range(SOLID_GRID_SIZE_Y):
			solid_grid.append(SolidType.None)
	
	for x in range(SOLID_GRID_SIZE_X):
		for y in range(floor(SOLID_GRID_SIZE_Y * .7), floor(SOLID_GRID_SIZE_Y * .9)):
			if (x+y)%20 > 10:
				solid_grid[x + y * SOLID_GRID_SIZE_X] = SolidType.Bedrock

func get_cell(x, y):
	return solid_grid[x + y * SOLID_GRID_SIZE_X]

func set_cell(x, y, type):
	solid_grid[x + y * SOLID_GRID_SIZE_X] = type
