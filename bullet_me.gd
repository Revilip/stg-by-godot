extends Node2D

var velocity

var tag = 11

var game_paused = false

func _process(delta):
	if game_paused:
		return
	translate(velocity*delta)
	if self.position.y < -100:
		queue_free()

func _ready():
	get_parent().connect("pause", self, "pause_switch")
	
func pause_switch():
	game_paused = !game_paused
