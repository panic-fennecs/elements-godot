extends Node2D

const WORLD_SIZE = Vector2(1280, 720)
const WIN_OVERLAY_FADE_SPEED = 0.1

enum GameState {
	main_game,
	win_screen
}

var kills = [0, 0]
var shakyness = 0
onready var start_time = OS.get_ticks_msec();
var game_state = GameState.main_game;
var overlay_fade = 0
var win_player = null

func _ready():
	update_labels()

func _process(delta):
	var elapsed_time = (OS.get_ticks_msec() - start_time) / 1000.0 # seconds
	position.x = sin(elapsed_time * 40) * shakyness;
	shakyness = shakyness * .88
	
	if game_state == GameState.win_screen:
		$WinOverlay.modulate = Color(1, 1, 1, min(max(overlay_fade, 0), 0.8))
		$"WinLabelWrapper".modulate = Color(1, 1, 1, min(max(overlay_fade-0.5, 0), 0.8))
		overlay_fade += WIN_OVERLAY_FADE_SPEED
		$WinOverlay.position = get_node(win_player).position + Vector2(0, -15)

func update_labels():
	$"/root/Main/Level/Player0Kills".text = str(kills[0])
	$"/root/Main/Level/Player1Kills".text = str(kills[1])

func player_won(id):
	if game_state == GameState.main_game:
		game_state = GameState.win_screen
		kills[id] += 1
		update_labels()
		$WinOverlay.visible = true
		if id == 0:
			$"WinLabelWrapper/WinLabel".text = "Blue Player Victory"
		else:
			$"WinLabelWrapper/WinLabel".text = "Red Player Victory"
		$"WinLabelWrapper".modulate = Color(1, 1, 1, 0)
		$WinLabelWrapper.visible = true
		overlay_fade = 0
		win_player = "Player" + str(id)

func in_game():
	return game_state == GameState.main_game

func try_restart():
	if game_state == GameState.win_screen and overlay_fade >= 2:
		new_game()

func new_game():
	game_state = GameState.main_game
	reset()
	$WinOverlay.visible = false
	$WinOverlay.modulate = Color(1, 1, 1, 0)
	$WinLabelWrapper.visible = false

func reset():
	$FluidManager.reset()
	$SolidManager.reset()
	$Player0.reset()
	$Player1.reset()

func shake(dmg):
	shakyness += dmg * .3;
