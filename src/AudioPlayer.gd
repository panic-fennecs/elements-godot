extends Node

const MIN_VOLUME_LEVEL = -45
const MAX_VOLUME_LEVEL = -12
const FADE_SPEED = 1

const BACKGROUND_STREAMS = [
	preload("res://res/audio/a_part_0.wav"),
	preload("res://res/audio/a_part_1.wav"),
	preload("res://res/audio/b_part_0.wav"),
	preload("res://res/audio/b_part_1.wav"),
	preload("res://res/audio/c_part_0.wav"),
	preload("res://res/audio/c_part_1.wav"),
]

var _current_music_player = null
var _fading_music_players = []

var _current_level = 0

class PlayerWrapper:
	var player
	var variation
	var level
	var volume
	
	func _init(level_arg):
		self.level = level_arg
		self.player = AudioStreamPlayer.new()
		self.player.stream = BACKGROUND_STREAMS[self.level*2]
		self.player.volume_db = MIN_VOLUME_LEVEL
		self.variation = 0
		self.volume = 0

	func play(from=0.0):
		self.player.play(from)

	func change_volume(delta):
		self.volume = clamp(self.volume + delta, 0, 1)
		self.player.volume_db = pow(self.volume, 1.0/4.0) * (-MIN_VOLUME_LEVEL + MAX_VOLUME_LEVEL) + MIN_VOLUME_LEVEL

	func next():
		self.variation = (self.variation + 1) % 2
		self.player.stream = BACKGROUND_STREAMS[self.level*2 + self.variation]
		self.player.play()

func _ready():
	$MusicTimer.connect("timeout", self, "_change_music")
	_current_music_player = PlayerWrapper.new(0)
	add_child(_current_music_player.player)
	_current_music_player.player.play()

func _get_stream_index(level, variation):
	return level*2 + variation

func _get_critical_level():
	var level = 0
	if $"/root/Main/Level".in_game():
		if $"/root/Main/Level/Player0".health < 50:
			level += 1
		if $"/root/Main/Level/Player1".health < 50:
			level += 1

	return level

func _change_music():
	_current_music_player.next()
	for player in _fading_music_players:
		player.next()

func _process(delta):
	var level = _get_critical_level()
	if level != _current_level:
		_fading_music_players.append(_current_music_player)
		var playing_position = _current_music_player.player.get_playback_position()
		_current_music_player = PlayerWrapper.new(level)
		add_child(_current_music_player.player)
		_current_music_player.play(playing_position)
		_current_level = level

	_current_music_player.change_volume(delta * FADE_SPEED)

	for fading_music_player in _fading_music_players:
		fading_music_player.change_volume(-delta * FADE_SPEED)
		if fading_music_player.volume <= 0:
			fading_music_player.player.stop()
			remove_child(fading_music_player.player)
			_fading_music_players.erase(fading_music_player)
