extends Node2D

const LIFETIME = 2
const ANCHOR_DIST = 4

var bound_to_player = null
var velocity = Vector2(0, 0)
var type = null
var _anchor = null
var lifetime = LIFETIME

const MAX_VELOCITY = 20

func init(player, type_):
	bound_to_player = player
	position = player.global_position
	_anchor = position
	type = type_

const CONTACT_FLUID_DIST = 0
func apply_contact_fluid_force(f): # vector from fluid to force-src
	pass 

const CONTACT_SOLID_DIST = 0
func apply_contact_solid_force(f): # vector from fluid to force-src
	pass # TODO make fluids drop down stairs

const CONTACT_CURSOR_DIST = 100
func apply_contact_cursor_force(f): # vector from fluid to force-src
	bound_to_player = null
	lifetime = LIFETIME
	_anchor = position
	velocity += f.normalized()

const CONTACT_BOUND_DIST = 100
func apply_contact_bound_force(f): # vector from fluid to force-src
	lifetime = LIFETIME
	velocity += f.normalized()

func sub_physics_process(delta):
	if bound_to_player:
		var v = bound_to_player.position - position
		if v.length_squared() > CONTACT_BOUND_DIST*CONTACT_BOUND_DIST: bound_to_player = null
		else: apply_contact_bound_force(v)

	apply_movement()

	velocity *= 0.99
	velocity += Vector2(0, 0.2)

func apply_movement():
	if velocity.length_squared() > MAX_VELOCITY*MAX_VELOCITY: velocity = velocity.normalized() * MAX_VELOCITY
	var sman = $"/root/Main/Level/SolidManager"
	var v = velocity
	for t in range(3):
		var cast = sman.raycast(position, v)
		if cast == null:
			position += v
			return
		else:
			if t == 2:
				return # this should not happen!
			var move_vector = cast[0] - position
			if abs(move_vector.x) > 0.1:
				position.x += move_vector.x * 0.95
			if abs(move_vector.y) > 0.1:
				position.y += move_vector.y * 0.95
			v -= move_vector
			var last_direction = cast[2]
			if last_direction.length_squared() == 0:
				velocity = Vector2.ZERO # fluid has glaitched!
				return
			if last_direction.x != 0:
				velocity.x = 0
				v.x = 0
			if last_direction.y != 0:
				velocity.y = 0
				v.y = 0

func get_enemy():
	var fman = $"/root/Main/Level/FluidManager"
	if type == fman.FluidType.Water:
		return $"/root/Main/Level/Player1"
	elif type == fman.FluidType.Lava:
		return $"/root/Main/Level/Player0"

func collides_player(player):
	var PLAYER_SIZE = player.PLAYER_SIZE
	return	position.x >= player.position.x - PLAYER_SIZE.x/2 and \
			position.x <= player.position.x + PLAYER_SIZE.x/2 and \
			position.y >= player.position.y - PLAYER_SIZE.y/2 and \
			position.y <= player.position.y + PLAYER_SIZE.y/2

func die():
	$"/root/Main/Level/FluidManager".fluids.erase(self)
	queue_free()

func _process(delta):
	var enemy = get_enemy()
	if collides_player(enemy):
		enemy.health -= 10
		die()
		return
	
	if _anchor != null:
		var v = position - _anchor
		if v.length_squared() <= ANCHOR_DIST:
			lifetime -= delta
			if lifetime <= 0:
				die()
				return
		else:
			_anchor = position
			lifetime = LIFETIME
