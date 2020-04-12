extends Node2D

const WORLD_SIZE = Vector2(1280, 720)
const TROPHY_MOVE_START_TIME = 0.65
const TROPHY_START_POSITION = Vector2(632, 322)

enum GameState {
	main_game,
	win_screen
}

var kills = [0, 0]
var shakyness = 0
onready var start_time = OS.get_ticks_msec();
var game_state = GameState.main_game;
var overlay_fade = 0
var win_player_id = null

func _ready():
	update_labels()

func _process(delta):
	var elapsed_time = (OS.get_ticks_msec() - start_time) / 1000.0 # seconds
	position.x = sin(elapsed_time * 40) * shakyness;
	shakyness = shakyness * .88
	
	if game_state == GameState.win_screen:
		$WinOverlay.modulate = Color(1, 1, 1, min(max(overlay_fade*2, 0), 0.85))
		$"WinLabelWrapper".modulate = Color(1, 1, 1, min(max(overlay_fade*1.5-0.5, 0), 1.0))
		$"WinTrophy".modulate = Color(1, 1, 1,clamp(overlay_fade*1.5-0.5, 0, 1))
		overlay_fade += delta
		$WinOverlay.position = get_node("Player" + str(win_player_id)).position + Vector2(0, -15)
		set_trophy_position()
		if overlay_fade >= 1.25:
			update_labels()

func set_trophy_position():
	var rel = clamp((overlay_fade - TROPHY_MOVE_START_TIME)  * 1.25, 0, 1)
	# rel = rel * rel * (3 - 2 * rel)
	# rel = sin((rel - 0.5) * PI) / 2 + 0.5
	rel = 6*pow(rel, 5) - 15*pow(rel, 4) + 10*pow(rel, 3)
	var target_position = get_node("/root/Main/Level/TrophyWrapper/Trophy" + str(win_player_id)).position
	$WinTrophy.position = TROPHY_START_POSITION * (1 - rel) + target_position * rel
	var scale = 2 - (rel  * 1.25)
	$WinTrophy.scale = Vector2(scale, scale)

func update_labels():
	$"/root/Main/Level/TrophyWrapper/Player0Kills".text = str(kills[0]) + "×"
	$"/root/Main/Level/TrophyWrapper/Player1Kills".text = str(kills[1]) + "×"

func player_won(id):
	if game_state == GameState.main_game:
		overlay_fade = 0
		game_state = GameState.win_screen
		AudioPlayer.player_won()
		kills[id] += 1
		$WinOverlay.visible = true
		if id == 0:
			$"WinLabelWrapper/WinLabel".text = "Blue Player Victory"
		else:
			$"WinLabelWrapper/WinLabel".text = "Red Player Victory"
		$"WinLabelWrapper".modulate = Color(1, 1, 1, 0)
		$WinLabelWrapper.visible = true
		$"WinTrophy".modulate = Color(1, 1, 1, 0)
		$WinTrophy.visible = true
		win_player_id = id

func in_game():
	return game_state == GameState.main_game

func try_restart():
	if game_state == GameState.win_screen and overlay_fade >= 1.5:
		new_game()

func new_game():
	game_state = GameState.main_game
	reset()
	$WinOverlay.visible = false
	$WinOverlay.modulate = Color(1, 1, 1, 0)
	$WinLabelWrapper.visible = false
	$WinTrophy.visible = false

func reset():
	AudioPlayer.reset()
	$FluidManager.reset()
	$SolidManager.reset()
	$Player0.reset()
	$Player1.reset()

func shake(dmg):
	shakyness += dmg * .3;
