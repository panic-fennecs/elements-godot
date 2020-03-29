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

var _velocity: Vector2 = Vector2.ZERO
var health = 100
var starting_pos = null

func _ready():
	if player_id == 1: $AnimatedSprite.flip_h = true
	$AnimatedSprite.self_modulate = player_color
	starting_pos = position

func lt(): return position - PLAYER_SIZE / 2

# sensor = [left-top, size]-rect in world coordinates
# the sensors are are within the player
# the sensors do not overlap and the four corners of the player have no sensors
func left_block():
	var s = [lt() + Vector2(0, SENSOR_DEPTH), Vector2(SENSOR_DEPTH, PLAYER_SIZE.y / 2)]
	return check_sensor(s)

func left_step_block():
	var s = [lt() + Vector2(-SENSOR_DEPTH, SENSOR_DEPTH + PLAYER_SIZE.y * 2 / 3), Vector2(SENSOR_DEPTH / 2, PLAYER_SIZE.y * 1 / 3 - 2*SENSOR_DEPTH)]
	return check_sensor(s)

func right_block():
	var s = [lt() + Vector2(PLAYER_SIZE.x - SENSOR_DEPTH, SENSOR_DEPTH), Vector2(SENSOR_DEPTH, PLAYER_SIZE.y / 2)]
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

func _physics_process(_delta) -> void:
	if _velocity.x > 0: _velocity.x = max(0, _velocity.x - DRAG)
	if _velocity.x < 0: _velocity.x = min(0, _velocity.x + DRAG)

	if Input.is_action_pressed("left_" + str(player_id)):
		_velocity.x -= MOVEMENT_FORCE
		$AnimatedSprite.flip_h = true
	if Input.is_action_pressed("right_" + str(player_id)):
		_velocity.x += MOVEMENT_FORCE
		$AnimatedSprite.flip_h = false
	if Input.is_action_just_pressed("jump_" + str(player_id)) and is_on_floor():
		_velocity.y = -JUMP_FORCE
	if Input.is_action_just_pressed("use_force_" + str(player_id)):
		# todo
		pass
	if Input.is_action_just_pressed("freeze_" + str(player_id)):
		# todo
		pass
	
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

func apply_movement():
	if left_block():
		_velocity.x = max(_velocity.x, 0)
	if _velocity.x > 0 and !right_block() and right_step_block() and !ceil_block():
		position.y -= STEP_HEIGHT
	if _velocity.x < 0 and !left_block() and left_step_block() and !ceil_block():
		position.y -= STEP_HEIGHT
	if right_block():
		_velocity.x = min(_velocity.x, 0)
	if up_block():
		_velocity.y = max(_velocity.y, 0)
	if bottom_block():
		_velocity.y = min(_velocity.y, 0)
	position += _velocity / 10

func _process(delta) -> void:
	$Healthbar.rect_size.x = PLAYER_SIZE.x * health / 100
	# todo idk perhaps this need also needs to be set into the physics loop
	var horizontal = Input.get_action_strength("aim_right_" + str(player_id)) - \
		Input.get_action_strength("aim_left_" + str(player_id))
	var vertical = Input.get_action_strength("aim_up_" + str(player_id)) - \
		Input.get_action_strength("aim_down_" + str(player_id))
	
	$ForceCursor.position = Vector2(horizontal, -vertical) * AIM_DISTANCE

func damage(dmg):
	health -= dmg
	if health <= 0:
		var enemy = 1-player_id
		$"/root/Main/Level".player_won(enemy)

func reset():
	health = 100
	position = starting_pos

func collides_point(point):
	return	point.x >= position.x - PLAYER_SIZE.x/2 and \
			point.x <= position.x + PLAYER_SIZE.x/2 and \
			point.y >= position.y - PLAYER_SIZE.y/2 and \
			point.y <= position.y + PLAYER_SIZE.y/2
