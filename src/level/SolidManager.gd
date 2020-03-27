extends Node2D

var SolidCollider = preload("res://src/level/SolidCollider.tscn")

const SOLID_GRID_SIZE_X = 128
const SOLID_GRID_SIZE_Y = 64
const SOLID_GRID_SIZE = Vector2(SOLID_GRID_SIZE_X, SOLID_GRID_SIZE_Y)
onready var SOLID_CELL_SIZE = $"/root/Main/Level".WORLD_SIZE / SOLID_GRID_SIZE

enum SolidType {
	None,
	Ice,
	Obsidian,
	Bedrock
}

var solid_grid = []
var collider_grid = []

func _ready():
	for x in range(SOLID_GRID_SIZE_X):
		for y in range(SOLID_GRID_SIZE_Y):
			solid_grid.append(SolidType.None)
	
	for x in range(SOLID_GRID_SIZE_X):
		for y in range(SOLID_GRID_SIZE_Y):
			collider_grid.append(null)
	
	for x in range(SOLID_GRID_SIZE_X):
		for y in range(35, 45):
			solid_grid[x + y * SOLID_GRID_SIZE_X] = true
			var rectangle = SolidCollider.instance()
			rectangle.position = Vector2(x, y) * SOLID_CELL_SIZE
			set_collider(x, y, rectangle)

func get_cell(x, y):
	return solid_grid[x + y * SOLID_GRID_SIZE_X]

func get_collider(x, y):
	return collider_grid[x + y * SOLID_GRID_SIZE_X]

func set_collider(x, y, new_collider):
	var collider = get_collider(x, y)
	if collider:
		collider.queue_free()
	collider = new_collider
	add_child(new_collider)
