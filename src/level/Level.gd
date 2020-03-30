extends Node2D

const WORLD_SIZE = Vector2(1280, 720)

var kills = [0, 0]
var shakyness = 0
onready var start_time = OS.get_ticks_msec();

func _ready():
	update_labels()

func _process(delta):
	var elapsed_time = (OS.get_ticks_msec() - start_time) / 1000.0 # seconds
	position.x = sin(elapsed_time * 40) * shakyness;
	shakyness = shakyness * .88

func update_labels():
	$"/root/Main/Level/Player0Kills".text = str(kills[0])
	$"/root/Main/Level/Player1Kills".text = str(kills[1])

func player_won(id):
	kills[id] += 1
	update_labels()
	reset()

func reset():
	$FluidManager.reset()
	$SolidManager.reset()
	$Player0.reset()
	$Player1.reset()

func shake(dmg):
	shakyness += dmg * .3;
