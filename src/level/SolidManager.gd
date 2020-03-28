extends Node2D

const SOLID_GRID_SIZE_X = 16*8
const SOLID_GRID_SIZE_Y = 9*8
const SOLID_GRID_SIZE = Vector2(SOLID_GRID_SIZE_X, SOLID_GRID_SIZE_Y)
onready var SOLID_CELL_SIZE = $"/root/Main/Level".WORLD_SIZE / SOLID_GRID_SIZE

const LIFETIME = 6

enum SolidType {
	None,
	Ice,
	Obsidian,
	Bedrock
}

var solid_grid = []
var lifetime_grid = []

func _ready():
	var image = Image.new()
	image.load("res://res/map/map01.png")
	
	image.lock()

	for y in range(SOLID_GRID_SIZE_Y):
		for x in range(SOLID_GRID_SIZE_X):
			var color = image.get_pixel(x, y)
			if color == Color.black:
				solid_grid.append(SolidType.Bedrock)
			elif color == Color.white:
				solid_grid.append(SolidType.None)
			else:
				print(color)
				assert(false)
			lifetime_grid.append(null)
	image.unlock()


func get_cell(x, y):
	return solid_grid[x + y * SOLID_GRID_SIZE_X]

func set_cell(x, y, type):
	if solid_grid[x + y * SOLID_GRID_SIZE_X] == SolidType.Bedrock: return
	solid_grid[x + y * SOLID_GRID_SIZE_X] = type
	if type == SolidType.Ice or type == SolidType.Obsidian:
		lifetime_grid[x + y * SOLID_GRID_SIZE_X] = LIFETIME
	else:
		lifetime_grid[x + y * SOLID_GRID_SIZE_X] = null

func raycast(from, vector): # returns null or [collision-point (from + vector * alpha), colliding tile position, direction]
	var C = 0 # 0.00000001
	var x = int(from.x / SOLID_CELL_SIZE.x)
	var y = int(from.y / SOLID_CELL_SIZE.y)
	var last_direction = Vector2(0, 0)
	while true:
		if x < 0 or y < 0 or x >= SOLID_GRID_SIZE_X or y >= SOLID_GRID_SIZE_Y or solid_grid[x + y * SOLID_GRID_SIZE.x] != SolidType.None:
			return [from, Vector2(x, y), last_direction]
		var dirx = 1
		if vector.x < 0: dirx = 0
		var diry = 1
		if vector.y < 0: diry = 0
		var tx = INF
		var ty = INF
		if vector.x != 0: tx = ((x+dirx) * SOLID_CELL_SIZE.x - from.x) / vector.x
		if vector.y != 0: ty = ((y+diry) * SOLID_CELL_SIZE.y - from.y) / vector.y

		if from.x == x * SOLID_CELL_SIZE.x and vector.x < 0: # if position is exactly on coordinate axis
			return [from, Vector2(x-1, y), Vector2(-1, 0)]
		if from.y == y * SOLID_CELL_SIZE.y and vector.y < 0:
			return [from, Vector2(x, y-1), Vector2(0, -1)]
		assert (tx >= 0)
		assert (ty >= 0)
		var change = 0
		if tx <= ty and tx <= 1:
			var cx = int(Vector2(vector.x, 0).normalized().x)
			x += cx
			change = vector * (tx + C)
			last_direction = Vector2(cx, 0)
		elif ty < tx and ty <= 1:
			var cy = int(Vector2(0, vector.y).normalized().y)
			y += cy
			change = vector * (ty + C)
			last_direction = Vector2(0, cy)
		else: return null
		vector -= change
		from += change

func _process(delta):
	for i in range(len(lifetime_grid)):
		if lifetime_grid[i] != null:
			lifetime_grid[i] -= delta
			if lifetime_grid[i] <= 0:
				lifetime_grid[i] = null
				solid_grid[i] = SolidType.None

func reset():
	for i in range(len(solid_grid)):
		lifetime_grid[i] = null
		if solid_grid[i] == SolidType.Ice or solid_grid[i] == SolidType.Obsidian:
			solid_grid[i] = SolidType.None
