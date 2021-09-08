extends Node2D

var tag = 9

var HP
var EP
var protected_time

var game_paused = false

var stage

func _ready():
	HP = 200
	EP = 20
	protected_time = 2
	stage = get_parent()
	stage.connect("pause", self, "pause_switch")
	
func _process(delta):
	if game_paused:
		return
	if protected_time > 0:
		protected_time -= delta

func _on_Area2D_area_entered(area):
	if stage.paused:
		return
	var temp_tag = area.get_parent().tag
	if temp_tag == 12:
		area.get_parent().queue_free()
		if protected_time <= 0:
			stage.get_node("pldead").play()
			HP -= 10
			EP = 20
			stage.emit_signal("clean_all")
			protected_time = 2
	elif temp_tag == 8:
		stage.get_node("item").play()
		area.get_parent().queue_free()
		HP = min(100, HP + 2)
	elif temp_tag == 7:
		stage.get_node("item").play()
		area.get_parent().queue_free()
		EP = min(100, EP + 5)
	elif temp_tag == 6:
		stage.get_node("item").play()
		area.get_parent().queue_free()
		stage.score += 100
	if HP < 0:
		var end_scene_instance = stage.end_scene.instance()
		end_scene_instance.string = " 满身疮痍！\n\nScore:%d\n\nPress <ENTER> To Retry" % [stage.score]
		stage.get_node("cover").add_child(end_scene_instance)
		stage.paused = true

func pause_switch():
	game_paused = !game_paused

func _on_graze_area_entered(area):
	if stage.paused:
		return
	var temp_tag = area.get_parent().tag
	if temp_tag == 12:
		stage.get_node("graze").play()
		stage.score += 100
