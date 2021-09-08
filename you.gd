extends Node2D

var tag = 10

var HP

var stage

func _ready():
	HP = 100
	stage = get_parent()
	
func _process(delta):
	if not stage.moving:
		rotation-=delta*10

func _on_Area2D_area_entered(area):
	var temp_tag = area.get_parent().tag
	if temp_tag == 11:
		get_parent().get_node("damage").play()
		HP -= 1
		area.get_parent().queue_free()
		get_parent().score += 20

func _on_body_attack_area_entered(area):
	pass
