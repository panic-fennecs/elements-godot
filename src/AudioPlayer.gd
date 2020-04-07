extends Node

var background_streams = [
	preload("res://res/audio/A_Part.wav"),
	preload("res://res/audio/B_Part.wav"),
	preload("res://res/audio/C_Part.wav")
]

var _background_players = []

func _ready():
	$MusicTimer.connect("timeout", self, "_change_music")
	for stream in background_streams:
		var player = AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = -12
		_background_players.append(player)
		add_child(player)

	_background_players[0].play()

func _get_critical_level():
	var level = 0
	if $"/root/Main/Level/Player0".health < 50:
		level += 1
	if $"/root/Main/Level/Player1".health < 50:
		level += 1
	return level

func _change_music():
	var level = _get_critical_level()
	_background_players[level].play()
