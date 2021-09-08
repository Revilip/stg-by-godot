extends Node2D

var time = 0

var game_paused = false

func _process(delta):
	if game_paused:
		return
	time += delta
	if time > 0.5:
		queue_free()

func _ready():
	get_parent().connect("pause", self, "pause_switch")
	
func pause_switch():
	game_paused = !game_paused
