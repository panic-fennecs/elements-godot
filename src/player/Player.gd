extends KinematicBody2D

const GRAVITY: float = 5.0
const MOVEMENT_FORCE: float = 20.0
const JUMP_FORCE: float = 200.0
const DRAG: float = 10.0
const MAX_SPEED: float = 200.0
const AIM_DISTANCE: float = 100.0

var _velocity: Vector2 = Vector2.ZERO

func _physics_process(_delta) -> void:
	if _velocity.x > 0: _velocity.x = max(0, _velocity.x - DRAG) 
	if _velocity.x < 0: _velocity.x = min(0, _velocity.x + DRAG) 
	
	if is_on_floor():
		_velocity.y = 0

	if Input.is_action_pressed("left"):
		_velocity.x -= MOVEMENT_FORCE
	if Input.is_action_pressed("right"):
		_velocity.x += MOVEMENT_FORCE
	if Input.is_action_just_pressed("jump") and is_on_floor():
		_velocity.y -= JUMP_FORCE
	if Input.is_action_just_pressed("use_force"):
		# todo
		pass
	if Input.is_action_just_pressed("freeze"):
		# todo
		pass
	
	_velocity.y += GRAVITY
	if _velocity.x > MAX_SPEED: _velocity.x = MAX_SPEED
	if _velocity.x < -MAX_SPEED: _velocity.x = -MAX_SPEED
	_velocity = move_and_slide(_velocity, Vector2.UP)

func _process(delta) -> void:
	var horizontal = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	var vertical = Input.get_action_strength("aim_up") - Input.get_action_strength("aim_down")
	
	$ForceCursor.position = Vector2(horizontal, -vertical).normalized() * AIM_DISTANCE
