extends Node2D

const MAX_NUM_FLUIDS = 5
const FLUID_COOLDOWN = 0.5
const FLUID_GRID_SIZE_X = 16
const FLUID_GRID_SIZE_Y = 9
const FLUID_GRID_SIZE_Z = 16
const FLUID_GRID_SIZE = Vector2(FLUID_GRID_SIZE_X, FLUID_GRID_SIZE_Y)
onready var FLUID_CELL_SIZE = $"/root/Main/Level".WORLD_SIZE / FLUID_GRID_SIZE

var p = preload("res://src/level/Fluid.tscn")

enum FluidType {
	Water,
	Lava
}
var counter = 0
var fluids = []

func get_fluid(grid, pos):
	var fluid_cell = grid[pos.x + pos.y * FLUID_GRID_SIZE_X];
	if pos.z < len(fluid_cell):
		return fluid_cell[pos.z]
	return null

func _add_fluid(cursor, type):
	var fluid = p.instance()
	add_child(fluid)
	fluid.init(cursor, type)
	fluids.append(fluid)

func _process(delta):
	counter += delta
	while counter > FLUID_COOLDOWN:
		counter -= FLUID_COOLDOWN
		_add_fluid($"/root/Main/Level/Player0/ForceCursor", FluidType.Water)
		_add_fluid($"/root/Main/Level/Player1/ForceCursor", FluidType.Lava)

func _physics_process(delta):
	for f in fluids:
		f.sub_physics_process(delta)
	if Input.is_action_just_pressed("use_force_0"):
		apply_cursor_pull(0)
	elif Input.is_action_just_released("use_force_0"):
		drop_cursor_pull(0)
	if Input.is_action_just_pressed("use_force_1"):
		apply_cursor_pull(1)
	elif Input.is_action_just_released("use_force_1"):
		drop_cursor_pull(1)
	
	apply_water_to_water_repel()
	apply_ice_to_water_repel()

func fluid_type_to_player(type):
	if type == FluidType.Water: return $"/root/Main/Level/Player0"
	if type == FluidType.Lava: return $"/root/Main/Level/Player1"

func solid_type_to_player(type):
	var sman = $"/root/Main/Level/SolidManager"
	if type == sman.SolidType.Ice: return $"/root/Main/Level/Player0"
	if type == sman.SolidType.Obsidian: return $"/root/Main/Level/Player1"

func apply_cursor_pull(player_id):
	var player = get_node("/root/Main/Level/Player" + str(player_id))
	var cursor = get_node("/root/Main/Level/Player" + str(player_id) + "/ForceCursor")
	for f in fluids:
		if fluid_type_to_player(f.type) == player:
			var v = cursor.global_position - f.position
			if v.length_squared() <= f.CURSOR_RADIUS*f.CURSOR_RADIUS:
				f.bind_to_cursor(cursor)

func drop_cursor_pull(player_id):
	var cursor = get_node("/root/Main/Level/Player" + str(player_id) + "/ForceCursor")
	for f in fluids:
		if f.bound_to == cursor:
			f.unbound_from_cursor()

func create_grid():
	var grid = [] 
	for x in range(FLUID_GRID_SIZE_X):
		for y in range(FLUID_GRID_SIZE_Y):
			grid.append([])
	
	for f in fluids:
		var p = (f.position / FLUID_CELL_SIZE).floor()
		grid[p.x + p.y * FLUID_GRID_SIZE.x].append(f)
	return grid

func apply_ice_to_water_repel():
	var sman = $"/root/Main/Level/SolidManager"
	if len(fluids) == 0: return
	if fluids[0].CONTACT_SOLID_DIST == 0: return
	var dx = fluids[0].CONTACT_SOLID_DIST / sman.SOLID_CELL_SIZE.x
	var dy = fluids[0].CONTACT_SOLID_DIST / sman.SOLID_CELL_SIZE.y
	for f in fluids:
		var x2min = max(0, floor(f.position.x / sman.SOLID_CELL_SIZE.x - dx))
		var x2max = min(sman.SOLID_GRID_SIZE.x, ceil(f.position.x / sman.SOLID_CELL_SIZE.x + dx + 1))
		var y2min = max(0, floor(f.position.y / sman.SOLID_CELL_SIZE.y - dy))
		var y2max = min(sman.SOLID_GRID_SIZE.y, ceil(f.position.y / sman.SOLID_CELL_SIZE.y + dy + 1))
		for x2 in range(x2min, x2max):
			for y2 in range(y2min, y2max):
				var v = Vector2(x2, y2) * sman.SOLID_CELL_SIZE - f.position# TODO fix offsets
				if sman.solid_grid[x2 + y2 * sman.SOLID_GRID_SIZE_X] and v.length_squared() <= f.CONTACT_SOLID_DIST*f.CONTACT_SOLID_DIST:
					f.apply_contact_solid_force(v)

func apply_water_to_water_repel():
	if len(fluids) == 0: return
	if fluids[0].CONTACT_FLUID_DIST == 0: return
	var grid = create_grid()
	var dx = int(fluids[0].CONTACT_FLUID_DIST / FLUID_CELL_SIZE.x) + 1
	var dy = int(fluids[0].CONTACT_FLUID_DIST / FLUID_CELL_SIZE.y) + 1

	for i in range(len(grid)):
		for f1 in grid[i]:
			var x1 = i % FLUID_GRID_SIZE_X
			var y1 = i / FLUID_GRID_SIZE_X
			var x2min = max(0, x1 - dx)
			var x2max = min(FLUID_GRID_SIZE_X, x1 + dx + 1)
			var y2min = max(0, y1 - dy)
			var y2max = min(FLUID_GRID_SIZE_Y, y1 + dy + 1)
			for x2 in range(x2min, x2max):
				for y2 in range(y2min, y2max):
					for f2 in grid[x2 + y2 * FLUID_GRID_SIZE_X]:
						if f1 == f2: continue
						var v = f2.position - f1.position
						if v.length_squared() <= f1.CONTACT_FLUID_DIST*f1.CONTACT_FLUID_DIST:
							f1.apply_contact_fluid_force(v)

func reset():
	for f in fluids:
		f.queue_free()
	fluids = []
	counter = 0
