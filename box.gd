extends Node2D

var tag = 7

var velocity = Vector2(0, 1)

var game_paused = false

func _process(delta):
	if game_paused:
		return
	translate(velocity)

func _ready():
	get_parent().connect("pause", self, "pause_switch")
	
func pause_switch():
	game_paused = !game_paused
