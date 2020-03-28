extends Node2D

const WORLD_SIZE = Vector2(1280, 720)

var kills = [0, 0]

func _ready():
	var g = load("res://bin/gdexample.gdns")
	var x = g.new()
	x.foo()
	update_labels()
	

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
