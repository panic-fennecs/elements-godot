extends Node2D

var bound_to_player = null
var velocity = Vector2(0, 0)
var type = null

const MAX_VELOCITY = 20

func init(player, type_):
	bound_to_player = player
	position = player.global_position
	type = type_

const CONTACT_FLUID_DIST = 100
func apply_contact_fluid_force(f): # vector from fluid to force-src
	if f.length_squared() < 5*5:
		velocity -= f.normalized()

const CONTACT_SOLID_DIST = 0
func apply_contact_solid_force(f): # vector from fluid to force-src
	pass # TODO make fluids drop down stairs

const CONTACT_CURSOR_DIST = 100
func apply_contact_cursor_force(f): # vector from fluid to force-src
	bound_to_player = null
	velocity += f.normalized()

const CONTACT_BOUND_DIST = 100
func apply_contact_bound_force(f): # vector from fluid to force-src
	velocity += f.normalized()

func sub_physics_process(delta):
	if bound_to_player:
		var v = bound_to_player.position - position
		if v.length_squared() > CONTACT_BOUND_DIST*CONTACT_BOUND_DIST: bound_to_player = null
		else: apply_contact_bound_force(v)

	apply_movement()

	velocity *= 0.99
	velocity += Vector2(0, 0.2)
	stay_in_view()

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
				pass # this should not happen!
			var move_vector = cast[0] - position
			if abs(move_vector.x) > 0.1:
				position.x += move_vector.x * 0.95
			if abs(move_vector.y) > 0.1:
				position.y += move_vector.y * 0.95
			v -= move_vector
			var last_direction = cast[2]
			if (last_direction.length_squared() == 0):
				assert(false) # some fluid has glitched!
			if last_direction.x != 0:
				velocity.x = 0
				v.x = 0
			if last_direction.y != 0:
				velocity.y = 0
				v.y = 0
	

func stay_in_view():
	var level_size = $"/root/Main/Level".WORLD_SIZE
	if position.x < 0:
		position.x = 0
		if velocity.x < 0:
			velocity.x = 1
	if position.y < 0:
		position.y = 0
		if velocity.y < 0:
			velocity.y = 1
	if position.x >= level_size.x:
		position.x = level_size.x-1
		if velocity.x > 0:
			velocity.x = -1
	if position.y >= level_size.y:
		position.y = level_size.y-1
		if velocity.y > 0:
			velocity.y = -1
	# choosing 1 and -1 as fallbacks makes the elements get some distance from the world border
