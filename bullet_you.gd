extends Node2D

var velocity = Vector2(0, 0)
var speed = 100

var tag = 12

var self_rot = 0
var normal_rot = 0

var rand_rot = 0
var begin_time = 0

var time = 0

var begin_destroy = false
var destroy_time = 0

func _ready():
# warning-ignore:return_value_discarded
	get_parent().connect("clean_all",self,"pre_destory")
	get_parent().connect("pause", self, "pause_switch")

var game_paused = false

func _process(delta):
	if game_paused:
		return
	if begin_destroy:
		destroy_time -= delta
		if destroy_time <= 0:
			destory()
	if self_rot:
		rotation += self_rot * delta
	if normal_rot or rand_rot:
		time += delta
		if time > begin_time:
			var temp = (normal_rot + rand_rot * randf()) * delta
			var v_x = cos(temp) * velocity.x - sin(temp) * velocity.y
			var v_y = cos(temp) * velocity.y + sin(temp) * velocity.x
			velocity = Vector2(v_x, v_y)
		#if rand_rot:
			#velocity += Vector2(-velocity.y,velocity.x) * 0.01 * rand_rot * (randi()%10)
	translate(velocity*delta)
	if self.position.y < -20 or self.position.y > 788 or self.position.x < -20 or self.position.x > 788:
		queue_free()

func pre_destory():
	if not begin_destroy:
		$Area2D.queue_free()
	begin_destroy = true
	destroy_time = randf() * 0.5

func destory():
	var fire = get_parent().fire.instance()
	fire.set("position", self.position)
	get_parent().add_child(fire)
	queue_free()
	
func pause_switch():
	game_paused = !game_paused
