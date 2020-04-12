extends Node

const MIN_VOLUME_LEVEL = -45
const MAX_VOLUME_LEVEL = -12
const FADE_SPEED = 5

const BACKGROUND_STREAMS = [
	preload("res://res/audio/a_part.wav"),
	preload("res://res/audio/a_part_cut.wav"),
	preload("res://res/audio/b_part.wav"),
	preload("res://res/audio/b_part_cut.wav"),
	preload("res://res/audio/c_part.wav"),
	preload("res://res/audio/c_part_cut.wav"),
]

const WHIZ = preload("res://res/audio/whiz.wav")

var _current_music_player = null
var _fading_music_players = []
var _sample_players = []

var _current_level = 0

class PlayerWrapper:
	var player
	var variation
	var level
	var volume
	
	func _init(level_arg, variation_arg=0, volume_arg=0):
		self.level = level_arg
		self.player = AudioStreamPlayer.new()
		self.player.stream = BACKGROUND_STREAMS[self.level*2 + variation_arg]
		self.variation = variation_arg
		self.volume = volume_arg
		self._update_volume_db()

	func play(from=0.0):
		self.player.play(from)

	func change_volume(delta):
		self.volume = clamp(self.volume + delta, 0, 1)
		self._update_volume_db()
	
	func _update_volume_db():
		self.player.volume_db = pow(self.volume, 1.0/4.0) * (-MIN_VOLUME_LEVEL + MAX_VOLUME_LEVEL) + MIN_VOLUME_LEVEL

	func refresh():
		self.player.stream = BACKGROUND_STREAMS[self.level*2 + self.variation]
		self.player.play()

func play_sample(sample, volume_db=0.0):
	var player = AudioStreamPlayer.new()
	player.stream = sample
	player.volume_db = volume_db
	add_child(player)
	_sample_players.append(player)
	player.play()

func _ready():
	$MusicRefreshTimer.connect("timeout", self, "_refresh_music")
	$ChangePartTimer.connect("timeout", self, "_change_music")
	$RestartTimer.connect("timeout", self, "_restart_music")
	_current_music_player = PlayerWrapper.new(0, 0, 1)
	add_child(_current_music_player.player)
	_current_music_player.player.play()

func _get_stream_index(level, variation):
	return level*2 + variation

func _get_critical_level():
	var level = 0
	if $"/root/Main/Level/Player0".health < 50:
		level += 1
	if $"/root/Main/Level/Player1".health < 50:
		level += 1

	return level

func player_won():
	_new_music(_current_level, 1)
	$ChangePartTimer.stop()

func reset():
	_stop_music()
	$MusicRefreshTimer.stop()
	$RestartTimer.start()
	$ChangePartTimer.start()

func _refresh_music():
	if _current_music_player != null:
		_current_music_player.refresh()
	for player in _fading_music_players:
		player.refresh()

func _restart_music():
	_new_music(0, 0, 1)
	$MusicRefreshTimer.start()
	$ChangePartTimer.start()

func _stop_music():
	if _current_music_player != null:
		_fading_music_players.append(_current_music_player)
	_current_music_player = null

func _new_music(level, variation=0, volume=0):
	var playing_position = 0
	if _current_music_player != null:
		_fading_music_players.append(_current_music_player)
		playing_position = _current_music_player.player.get_playback_position()

	_current_music_player = PlayerWrapper.new(level, variation, volume)
	add_child(_current_music_player.player)
	_current_music_player.play(playing_position)
	_current_level = level

func _change_music():
	var level = _get_critical_level()
	if level != _current_level:
		_new_music(level)

func _process(delta):
	if _current_music_player != null:
		_current_music_player.change_volume(delta * FADE_SPEED)

	for fading_music_player in _fading_music_players:
		fading_music_player.change_volume(-delta * FADE_SPEED)
		if fading_music_player.volume <= 0:
			fading_music_player.player.stop()
			remove_child(fading_music_player.player)
			_fading_music_players.erase(fading_music_player)
			break

	for player in _sample_players:
		if not player.playing:
			remove_child(player)
			_sample_players.erase(player)
			break
