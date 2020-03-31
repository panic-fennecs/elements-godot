extends Node2D

export(Color) var player_color: Color = Color.white
export(int) var player_id: int

const GRAVITY: float = 6.0
const MOVEMENT_FORCE: float = 10.0
const JUMP_FORCE: float = 100.0
const DRAG: float = 3.0
const MAX_SPEED: float = 50.0
const AIM_DISTANCE: float = 100.0
const IDLE_SPEED = 20

const PLAYER_SIZE = Vector2(27, 54)
const SENSOR_DEPTH = 5
const GROUNDED_SENSOR_DEPTH = 10
const STEP_HEIGHT = 10
const SOLIDS_PER_FLUID = 5

var _velocity: Vector2 = Vector2.ZERO
var health = 100
var starting_pos = null
var last_solid_place_world_pos = null
var free_solids = 0

func _ready():
	if player_id == 1: $AnimatedSprite.flip_h = true
	$AnimatedSprite.self_modulate = player_color
	starting_pos = position

func lt(): return position - PLAYER_SIZE / 2

# sensor = [left-top, size]-rect in world coordinates
# the sensors are are within the player
# the sensors do not overlap and the four corners of the player have no sensors
func left_block():
	var s = [lt() + Vector2(0, SENSOR_DEPTH), Vector2(SENSOR_DEPTH, PLAYER_SIZE.y * 0.4)]
	return check_sensor(s)

func left_step_block():
	var s = [lt() + Vector2(0, SENSOR_DEPTH + PLAYER_SIZE.y * 2 / 3), Vector2(SENSOR_DEPTH / 2, PLAYER_SIZE.y * 1 / 3 - 2*SENSOR_DEPTH)]
	return check_sensor(s)

func right_block():
	var s = [lt() + Vector2(PLAYER_SIZE.x - SENSOR_DEPTH, SENSOR_DEPTH), Vector2(SENSOR_DEPTH, PLAYER_SIZE.y * 0.4)]
	return check_sensor(s)

func right_step_block():
	var s = [lt() + Vector2(PLAYER_SIZE.x - SENSOR_DEPTH, SENSOR_DEPTH + PLAYER_SIZE.y * 2 / 3), Vector2(SENSOR_DEPTH / 2, PLAYER_SIZE.y * 1 / 3 - 2*SENSOR_DEPTH)]
	return check_sensor(s)

func up_block():
	var C = 5
	var s = [lt() + Vector2(C, 0), Vector2(PLAYER_SIZE.x - 2*C, SENSOR_DEPTH)]
	return check_sensor(s)

func bottom_block():
	var s = [lt() + Vector2(SENSOR_DEPTH, PLAYER_SIZE.y - SENSOR_DEPTH), Vector2(PLAYER_SIZE.x - 2*SENSOR_DEPTH, SENSOR_DEPTH)]
	return check_sensor(s)
	
func grounded_block():
	var C = 10
	var s = [lt() + Vector2(-C, PLAYER_SIZE.y), Vector2(PLAYER_SIZE.x + 2*C, GROUNDED_SENSOR_DEPTH)]
	return check_sensor(s)

func ceil_block(): # = up_block if position.y -= STEP_HEIGHT
	var C = 5
	var s = [lt() + Vector2(C, -STEP_HEIGHT), Vector2(PLAYER_SIZE.x - 2*C, SENSOR_DEPTH + STEP_HEIGHT)]
	return check_sensor(s)

func check_sensor(sensor):
	var left_top = sensor[0]
	var size = sensor[1]
	var sman = $"/root/Main/Level/SolidManager"
	
	var xmin = max(0, int(left_top.x / sman.SOLID_CELL_SIZE.x))
	var xmax = min(sman.SOLID_GRID_SIZE.x, int((left_top.x + size.x) / sman.SOLID_CELL_SIZE.x + 1))
	var ymin = max(0, int(left_top.y / sman.SOLID_CELL_SIZE.y))
	var ymax = min(sman.SOLID_GRID_SIZE.y, int((left_top.y + size.y) / sman.SOLID_CELL_SIZE.y + 1))
	for x in range(xmin, xmax):
		for y in range(ymin, ymax):
			if sman.solid_grid[x + y * sman.SOLID_GRID_SIZE.x] != sman.SolidType.None:
				return true
	return false

func is_on_floor():
	return grounded_block()

func get_bound_fluids():
	var fman = $"/root/Main/Level/FluidManager"
	var l = []
	for f in fman.fluids:
		if fman.fluid_type_to_player(f.type) == self and f.bound_to:
			l.append(f)
	return l

func allocate_free_solid():
	var bound = get_bound_fluids()
	if free_solids + len(bound) * SOLIDS_PER_FLUID < 1: return false
	while free_solids < 1:
		var f = bound[0]
		bound.erase(f)
		f.die()
		free_solids += SOLIDS_PER_FLUID
	return true

func freeze_point(x, y):
	var sman = $"/root/Main/Level/SolidManager"
	if sman.get_cell(x, y) != sman.SolidType.None: return
	for player in [$"/root/Main/Level/Player0", $"/root/Main/Level/Player1"]:
		if player.collides_point(Vector2(x, y) * sman.SOLID_CELL_SIZE) or \
			player.collides_point(Vector2(x + 1, y) * sman.SOLID_CELL_SIZE) or \
			player.collides_point(Vector2(x, y + 1) * sman.SOLID_CELL_SIZE) or \
			player.collides_point(Vector2(x + 1, y + 1) * sman.SOLID_CELL_SIZE):
			return
	if allocate_free_solid():
		sman.set_cell(x, y, [sman.SolidType.Ice, sman.SolidType.Obsidian][player_id])
		free_solids -= 1

func do_freeze_skill():
	var SCS = $"/root/Main/Level/SolidManager".SOLID_CELL_SIZE
	var curr_x = int($ForceCursor.global_position.x / SCS.x)
	var curr_y = int($ForceCursor.global_position.y / SCS.y)
	
	if last_solid_place_world_pos == null:
		freeze_point(curr_x, curr_y)
	else:
		for i in range(10):
			var x = int(last_solid_place_world_pos.x / SCS.x) * (9-i) / 9 + curr_x * i / 9
			var y = int(last_solid_place_world_pos.y / SCS.y) * (9-i) / 9 + curr_y * i / 9
			freeze_point(x, y)
	last_solid_place_world_pos = $ForceCursor.global_position

func reset_freeze_skill():
	free_solids = 0
	last_solid_place_world_pos = null

func get_vec_sum(vec):
	return vec.x + vec.y + vec.z

func _physics_process(_delta) -> void:
	if _velocity.x > 0: _velocity.x = max(0, _velocity.x - DRAG)
	if _velocity.x < 0: _velocity.x = min(0, _velocity.x + DRAG)
	
	if _velocity.x > MAX_SPEED: _velocity.x = MAX_SPEED
	if _velocity.x < -MAX_SPEED: _velocity.x = -MAX_SPEED
	if !bottom_block():
		_velocity.y += GRAVITY

	apply_movement()

	if is_on_floor():
		if abs(_velocity.x) < IDLE_SPEED:
			$AnimatedSprite.play("idle" + str(player_id))
		else:
			$AnimatedSprite.play("run" + str(player_id))
	else:
		if _velocity.y < -30:
			$AnimatedSprite.play("jump" + str(player_id))
		elif _velocity.y < 30:
			$AnimatedSprite.play("fallslow" + str(player_id))
		else:
			$AnimatedSprite.play("fall" + str(player_id))

class FluidSorter:
	var root_pos
	func _init(root_pos):
		self.root_pos = root_pos

	func sort_fluids(f1, f2):
		return (f1.position - self.root_pos).length_squared() < (f2.position - self.root_pos).length_squared()

const NUM_DROP_SOME = 3
func _drop_some():
	var fman = $"/root/Main/Level/FluidManager"
	var sum_speed = Vector2.ZERO
	var avg_position = Vector2.ZERO
	var own_fluids = []
	for f in fman.fluids:
		if fman.fluid_type_to_player(f.type) == self and f.bound_to:
			own_fluids.append(f)
			sum_speed += f.velocity
			avg_position += f.position

	avg_position /= len(own_fluids)

	var best_fluid = null
	var best_value = null
	for own_fluid in own_fluids:
		var value = (own_fluid.position - avg_position).dot(sum_speed)
		if best_value == null or value > best_value:
			best_value = value
			best_fluid = own_fluid
	if own_fluids.empty():
		return
	own_fluids.erase(best_fluid)
	own_fluids.sort_custom(FluidSorter.new(best_fluid.position), "sort_fluids")

	best_fluid.bound_to = null
	best_fluid.position += best_fluid.velocity * 3

	var chosen_fluids = [best_fluid]

	for i in range(min(NUM_DROP_SOME - 1, len(own_fluids))):
		chosen_fluids.append(own_fluids[i])

	for f in chosen_fluids:
		f.bound_to = null
		f.velocity = best_fluid.velocity
		f.position = best_fluid.position + (f.position - best_fluid.position).normalized() * 15

	if len(chosen_fluids) == 3:
		chosen_fluids[1].position = chosen_fluids[2].position + (chosen_fluids[1].position - chosen_fluids[2].position).normalized() * 15

func apply_movement():
	var n = int(_velocity.length())
	for i in range(n):
		if _velocity.x > 0 and !right_block() and right_step_block() and !ceil_block():
			position.y -= STEP_HEIGHT
		if _velocity.x < 0 and !left_block() and left_step_block() and !ceil_block():
			position.y -= STEP_HEIGHT
		if left_block():
			_velocity.x = max(_velocity.x, 0)
		if right_block():
			_velocity.x = min(_velocity.x, 0)
		if up_block():
			_velocity.y = max(_velocity.y, 0)
		if bottom_block():
			_velocity.y = min(_velocity.y, 0)
		position += _velocity / (10 * n)

func _input(event):
	if event.is_action_pressed("jump_" + str(player_id)) and is_on_floor():
		_velocity.y = -JUMP_FORCE

func _process(delta) -> void:
	$Healthbar.rect_size.x = PLAYER_SIZE.x * health / 100

	if $"/root/Main/Level".in_game():
		# todo idk perhaps this need also needs to be set into the physics loop
		var horizontal = Input.get_action_strength("aim_right_" + str(player_id)) - \
			Input.get_action_strength("aim_left_" + str(player_id))
		var vertical = Input.get_action_strength("aim_up_" + str(player_id)) - \
			Input.get_action_strength("aim_down_" + str(player_id))
		$ForceCursor.position = Vector2(horizontal, -vertical) * AIM_DISTANCE
	else:
		$ForceCursor.position = Vector2.ZERO
	
	var level = $"/root/Main/Level"
	if not level.in_game():
		for action in ["freeze_", "use_force_"]:
			if Input.is_action_pressed(action + str(player_id)):
				$"/root/Main/Level".try_restart()
	else:
		if Input.is_action_pressed("left_" + str(player_id)):
			_velocity.x -= MOVEMENT_FORCE
			$AnimatedSprite.flip_h = true
		if Input.is_action_pressed("right_" + str(player_id)):
			_velocity.x += MOVEMENT_FORCE
			$AnimatedSprite.flip_h = false
		if Input.is_action_just_pressed("drop_few_" + str(player_id)):
			self._drop_some()

		if Input.is_action_pressed("freeze_" + str(player_id)):
			do_freeze_skill()
		else:
			reset_freeze_skill()

func damage(dmg):
	var level = $"/root/Main/Level"
	health -= dmg
	level.shake(dmg);
	if health <= 0:
		var enemy = 1-player_id
		level.player_won(enemy)

func reset():
	health = 100
	position = starting_pos
	reset_freeze_skill()

func collides_point(point):
	return	point.x >= position.x - PLAYER_SIZE.x/2 and \
			point.x <= position.x + PLAYER_SIZE.x/2 and \
			point.y >= position.y - PLAYER_SIZE.y/2 and \
			point.y <= position.y + PLAYER_SIZE.y/2
