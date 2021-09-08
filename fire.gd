extends Node2D

var time = 0

func _ready():
	$AnimatedSprite.play()

func _process(delta):
	time += delta
	if time > 0.3:
		queue_free()
