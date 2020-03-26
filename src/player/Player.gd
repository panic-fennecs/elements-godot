extends KinematicBody2D

export(Color) var player_color: Color = Color.white
export(int) var player_id: int

const GRAVITY: float = 5.0
const MOVEMENT_FORCE: float = 20.0
const JUMP_FORCE: float = 200.0
const DRAG: float = 10.0
const MAX_SPEED: float = 200.0
const AIM_DISTANCE: float = 100.0

var _velocity: Vector2 = Vector2.ZERO

func _ready():
	if player_id == 1: $AnimatedSprite.flip_h = true
	$AnimatedSprite.self_modulate = player_color

func _physics_process(_delta) -> void:
	if _velocity.x > 0: _velocity.x = max(0, _velocity.x - DRAG) 
	if _velocity.x < 0: _velocity.x = min(0, _velocity.x + DRAG) 
	
	if is_on_floor():
		_velocity.y = 0

	if Input.is_action_pressed("left_" + str(player_id)):
		_velocity.x -= MOVEMENT_FORCE
		$AnimatedSprite.flip_h = true
	if Input.is_action_pressed("right_" + str(player_id)):
		_velocity.x += MOVEMENT_FORCE
		$AnimatedSprite.flip_h = false
	if Input.is_action_just_pressed("jump_" + str(player_id)) and is_on_floor():
		_velocity.y -= JUMP_FORCE
	if Input.is_action_just_pressed("use_force_" + str(player_id)):
		# todo
		pass
	if Input.is_action_just_pressed("freeze_" + str(player_id)):
		# todo
		pass
	
	_velocity.y += GRAVITY
	if _velocity.x > MAX_SPEED: _velocity.x = MAX_SPEED
	if _velocity.x < -MAX_SPEED: _velocity.x = -MAX_SPEED
	_velocity = move_and_slide(_velocity, Vector2.UP)

func _process(delta) -> void:
	# todo idk perhaps this need also needs to be set into the physics loop
	var horizontal = Input.get_action_strength("aim_right_" + str(player_id)) - \
		Input.get_action_strength("aim_left_" + str(player_id))
	var vertical = Input.get_action_strength("aim_up_" + str(player_id)) - \
		Input.get_action_strength("aim_down_" + str(player_id))
	
	$ForceCursor.position = Vector2(horizontal, -vertical).normalized() * AIM_DISTANCE
