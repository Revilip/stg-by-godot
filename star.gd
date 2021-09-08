extends Node2D

var velocity = Vector2(0,0)
var speed = 200

var tag = 12

var time = 0

var count = 4

var begin_destroy = false
var destroy_time = 0

var game_paused = false

func _ready():
# warning-ignore:return_value_discarded
	get_parent().connect("clean_all",self,"pre_destory")
	get_parent().connect("pause", self, "pause_switch")

func _process(delta):
	if game_paused:
		return
	if begin_destroy:
		destroy_time -= delta
		if destroy_time <= 0:
			destory()
	time += delta
	rotation += delta
	if count > 0 and time >= 1:
		get_parent().get_node("tan").play()
		time = 0
		var offset = randi()
		for i in 5:
			var bullet = get_parent().summon_your_star()
			bullet.set("position", self.position)
			offset = PI/5*2+offset
			bullet.velocity = Vector2(cos(offset),sin(offset)) * speed
			bullet.count = count - 1
			bullet.time = i*delta
			bullet.speed = speed - 40
		queue_free()
	translate(velocity*delta)
	if self.position.y < -20 or self.position.y > 788 or self.position.x < -20 or self.position.x > 788:
		queue_free()

func pre_destory():
	begin_destroy = true
	destroy_time = randf() * 0.5

func destory():
	var fire = get_parent().fire.instance()
	fire.set("position", self.position)
	get_parent().add_child(fire)
	queue_free()
	
func pause_switch():
	game_paused = !game_paused
