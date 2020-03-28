extends Node2D

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

func _add_fluid(player, type):
	var fluid = p.instance()
	fluid.init(player, type)
	fluids.append(fluid)
	add_child(fluid)

func _process(delta):
	var freeze_radius = 4.0
	
	if Input.is_action_pressed("freeze_0") or Input.is_action_pressed("freeze_1"):
		var i = len(fluids) - 1
		while i >= 0:
			var fluid = fluids[i]
			var l = 10000.0
			var solid_type
			if Input.is_action_pressed("freeze_0") and fluid.type == FluidType.Water:
				l = ($"/root/Main/Level/Player0/ForceCursor".global_position - fluid.position).length()
				solid_type = $"../SolidManager".SolidType.Ice
			elif Input.is_action_pressed("freeze_1") and fluid.type == FluidType.Lava:
				l = ($"/root/Main/Level/Player1/ForceCursor".global_position - fluid.position).length()
				solid_type = $"../SolidManager".SolidType.Obsidian
			
			if not fluid.bound_to_player and l < FLUID_GRID_SIZE_Y * freeze_radius:
				var cell_pos = fluid.position / $"/root/Main/Level".WORLD_SIZE * $"../SolidManager".SOLID_GRID_SIZE
				cell_pos = cell_pos.floor()
				$"../SolidManager".set_cell(cell_pos.x, cell_pos.y, solid_type)
				$"../SolidManager".set_cell(cell_pos.x - 1, cell_pos.y, solid_type)
				$"../SolidManager".set_cell(cell_pos.x + 1, cell_pos.y, solid_type)
				$"../SolidManager".set_cell(cell_pos.x, cell_pos.y - 1, solid_type)
				$"../SolidManager".set_cell(cell_pos.x, cell_pos.y + 1, solid_type)
				$"../SolidManager".set_cell(cell_pos.x + 1, cell_pos.y - 1, solid_type)
				$"../SolidManager".set_cell(cell_pos.x + 1, cell_pos.y + 1, solid_type)
				$"../SolidManager".set_cell(cell_pos.x + 2, cell_pos.y, solid_type)
				fluids.erase(fluid)
			i = i - 1
				
	counter += delta
	while counter > 1:
		counter -= 1
		_add_fluid($"/root/Main/Level/Player0", FluidType.Water)
		_add_fluid($"/root/Main/Level/Player1", FluidType.Lava)

func _physics_process(delta):
	for f in fluids:
		f.sub_physics_process(delta)
	if Input.is_action_pressed("use_force_0"):
		apply_cursor_pull(0)
	if Input.is_action_pressed("use_force_1"):
		apply_cursor_pull(1)
	apply_water_to_water_repel()
	apply_ice_to_water_repel()

func type_to_player(type):
	if type == FluidType.Water: return $"/root/Main/Level/Player0"
	if type == FluidType.Lava: return $"/root/Main/Level/Player1"

func apply_cursor_pull(player_id):
	var player = get_node("/root/Main/Level/Player" + str(player_id))
	var cursor = get_node("/root/Main/Level/Player" + str(player_id) + "/ForceCursor")
	for f in fluids:
		if type_to_player(f.type) == player:
			var v = cursor.global_position - f.position
			if v.length_squared() <= f.CONTACT_CURSOR_DIST*f.CONTACT_CURSOR_DIST:
				f.apply_contact_cursor_force(v)

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
