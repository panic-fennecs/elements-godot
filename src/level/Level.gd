extends Node2D

const WORLD_SIZE = Vector2(2*956, 1045)

func _ready():
	var g = load("res://bin/gdexample.gdns")
	var x = g.new()
	x.foo()
