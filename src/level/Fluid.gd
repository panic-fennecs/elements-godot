extends Node2D

const ENEMY_DAMAGE = 5

var bound_to = null # may be null / player / cursor
var velocity = Vector2(0, 0)
var type = null
var age = 0

const MAX_VELOCITY = 20

func init(cursor, type_):
	var fman = $"/root/Main/Level/FluidManager"
	var player_id = fman.fluid_type_to_player(type_).player_id
	if Input.is_action_pressed("use_force_" + str(player_id)):
		bound_to = cursor
	position = cursor.global_position + Vector2(randf()*0.001, randf()*0.001)
	type = type_

const CONTACT_FLUID_DIST = 30
func apply_contact_fluid_force(f): # vector from fluid to force-src
	if (f == Vector2(0, 0)):
		f = Vector2(0.0001, 0)
	var intensity = cos(f.length()  * PI / 40) * 1.2 + 0.15
	velocity -= f.normalized() * intensity

const CONTACT_SOLID_DIST = 20
func apply_contact_solid_force(f): # vector from fluid to force-src
	pass # velocity -= f / 2000

const CURSOR_RADIUS = 100
func apply_bound_force(): # vector from fluid to force-src
	var t = (bound_to.global_position - position) / 7
	var M = 10
	if t.length() > M: t.normalized() * M
	velocity += t

func bind_to_cursor(cursor):
	bound_to = cursor

func unbound_from_cursor():
	bound_to = null

func sub_physics_process(delta):
	if bound_to: apply_bound_force()

	apply_movement()

	velocity *= 1
	if bound_to: velocity *= 0.85
	velocity *= 0.994
	velocity += Vector2(0, 0.2)

const RANDOM_FORCE_STRENGTH = 0.06
func apply_movement():
	if velocity.length_squared() > MAX_VELOCITY*MAX_VELOCITY: velocity = velocity.normalized() * MAX_VELOCITY
	var sman = $"/root/Main/Level/SolidManager"
	var v = velocity
	for t in range(3):
		var cast = sman.raycast(position, v)
		if cast == null:
			position += v
			break
		else:
			if t == 2:
				break # this should not happen!
			var move_vector = cast[0] - position
			if abs(move_vector.x) > 0.1:
				position.x += move_vector.x * 0.95
			if abs(move_vector.y) > 0.1:
				position.y += move_vector.y * 0.95
			v -= move_vector
			var last_direction = cast[2]
			if last_direction.length_squared() == 0:
				velocity = Vector2.ZERO # fluid has glitched!
				break
			if last_direction.x != 0:
				var random_force = Vector2(randf()*-last_direction.x*0.7, randf()-0.5) * velocity.length_squared() * RANDOM_FORCE_STRENGTH
				velocity.x = 0
				velocity += random_force
				v.x = 0
			if last_direction.y != 0:
				var random_force = Vector2(randf()-0.5, randf()*-last_direction.y*0.5) * velocity.length_squared() * RANDOM_FORCE_STRENGTH
				velocity.y = 0
				velocity += random_force
				v.y = 0

func get_enemy():
	var fman = $"/root/Main/Level/FluidManager"
	if type == fman.FluidType.Water:
		return $"/root/Main/Level/Player1"
	elif type == fman.FluidType.Lava:
		return $"/root/Main/Level/Player0"

func collides_player(player):
	var EXTRA = 6
	var PLAYER_SIZE = player.PLAYER_SIZE
	return	position.x + EXTRA >= player.position.x - PLAYER_SIZE.x/2 and \
			position.x - EXTRA <= player.position.x + PLAYER_SIZE.x/2 and \
			position.y + EXTRA >= player.position.y - PLAYER_SIZE.y/2 and \
			position.y - EXTRA <= player.position.y + PLAYER_SIZE.y/2

func die():
	$"/root/Main/Level/FluidManager".fluids.erase(self)
	queue_free()

# returns bool
func death_chance(delta):
	return randf() < delta * 0.025

func _process(delta):
	if !is_instance_valid(self): return
	var enemy = get_enemy()
	if collides_player(enemy):
		enemy.damage(ENEMY_DAMAGE)
		die()
		return
	age += delta
	if death_chance(delta):
		die()
