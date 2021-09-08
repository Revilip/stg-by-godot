extends Node2D

const speed_me = 300

var velocity_me

var shoot_time_count = 0
var bomb_time_count = 0

var card_time = 0.0
var old_card_time = 0.0
var check_card_time = [0, 0, 0]
var end_card_time = 0
var time_offset = 0.0

var card_count = 0

var card_health = 100.0

var moving = false

var supply_count = 0

var pre_me_bullet = preload("res://main/bullet_me.tscn")
var pre_you_bullet = preload("res://main/bullet_you.tscn")
var pre_you_bomb = preload("res://main/bomb_you.tscn")
var pre_you_star = preload("res://main/star.tscn")
var pre_you_normal_star = preload("res://main/star_you.tscn")
var pre_you_purple_star = preload("res://main/purple_star.tscn")
var pre_you_large_bomb = preload("res://main/large_bomb_you.tscn")

var pre_health = preload("res://main/health.tscn")
var pre_box = preload("res://main/box.tscn")
var pre_point = preload("res://main/point.tscn")

var end_scene = preload("res://main/end.tscn")
var fire = preload("res://main/fire.tscn")
var bomb = preload("res://main/bomb.tscn")

var score = 0

var paused = false

var game_paused = false
var pause_time = 0

signal clean_all()
signal pause()

func _ready():
# warning-ignore:return_value_discarded
	connect("clean_all",self,"clean_all_event")
	$AudioStreamPlayer.play()

func _process(delta):
	#ui:
	$ui/Label2.text = "score:%d\ntime left:%d\nbgm:遥か３８万キロのボヤージュ" % [score, end_card_time - card_time]
	$ui/HP.rect_scale.x = max($me.HP / 100.0, 0)
	$ui/EP.rect_scale.x = max($me.EP / 100.0, 0)
	if bomb_time_count == 0 and $me.EP >= 20:
		$ui/EP.color = Color(0.1, 0.7, 0.22, 0.49)
	else:
		$ui/EP.color = Color(0.5, 0.5, 0.5, 0.49)
	$ui/HP_you.rect_scale.x = max($you.HP / card_health, 0)
	if paused:
		if Input.is_action_pressed("slow"):
			$upper/sign.set("position", $me.position)
		else:
			$upper/sign.set("position", Vector2(30, -30))
		if Input.is_action_pressed("ui_accept"):
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://main/scene.tscn")
		return
	if Input.is_action_just_pressed("esc"):
		if pause_time > 1 or not game_paused:
			pause_time = 0
			game_paused = !game_paused
			$pause_layer/pause/ColorRect.visible = game_paused
			$pause_layer/pause/Label.visible = game_paused
			emit_signal("pause")
	if game_paused:
		if Input.is_action_pressed("replay"):
			get_tree().change_scene("res://main/scene.tscn")
		pause_time += delta
		return
	card_process(delta)
	#input process:
	velocity_me = Vector2(0, 0)
	if Input.is_action_pressed("ui_up"):
		velocity_me += Vector2(0,-1) * speed_me
	if Input.is_action_pressed("ui_down"):
		velocity_me += Vector2(0,1) * speed_me
	if Input.is_action_pressed("ui_left"):
		velocity_me += Vector2(-1,0) * speed_me
	if Input.is_action_pressed("ui_right"):
		velocity_me += Vector2(1,0) * speed_me
	if Input.is_action_pressed("slow"):
		velocity_me *= 0.5
	if velocity_me.y < 0 and $me.position.y < 4:
		velocity_me.y = 0
	if velocity_me.y > 0 and $me.position.y > 764:
		velocity_me.y = 0
	if velocity_me.x < 0 and $me.position.x < 4:
		velocity_me.x = 0
	if velocity_me.x > 0 and $me.position.x > 764:
		velocity_me.x = 0
	$me.translate(velocity_me*delta)
	if Input.is_action_pressed("slow"):
		$upper/sign.set("position", $me.position)
	else:
		$upper/sign.set("position", Vector2(30, -30))
	if Input.is_action_pressed("key_z"):
		if shoot_time_count == 0:
			shoot_time_count = 5
			summon_my_bullet()
	if Input.is_action_pressed("key_x"):
		if bomb_time_count == 0 and $me.EP >= 20:
			$cat.play()
			var bomb_instance = bomb.instance()
			bomb_instance.set("position", self.position)
			add_child(bomb_instance)
			$me.EP -= 10
			$me.protected_time = 2
			bomb_time_count = 50
			emit_signal("clean_all")
			$you.HP -= 20
	shoot_time_count = max(0, shoot_time_count-1)
	bomb_time_count = max(0, bomb_time_count-1)

func clean_all_event():
	time_offset = card_time

func card_process(delta):
	if not moving:
		old_card_time = card_time
		card_time += delta*50
	if randi()%100 == 0:
		if randi()%10:
			summon_supply_point(Vector2(randf() * 760 + 4, -10))
		else:
			summon_supply_box(Vector2(randf() * 760 + 4, -10))
	if card_time > end_card_time or $you.HP <= 0:
		if card_count > 1:
			$enep.play()
		emit_signal("clean_all")
		if $you.HP <= 0:
			score += 1000
		var bomb_instance = bomb.instance()
		bomb_instance.set("position", self.position)
		add_child(bomb_instance)
		#card_count = 6
		card_count += 1
		card_time = 0.0
		time_offset = 0.0
		check_card_time = [0, 0, 0]
		$ui/Label.text = ""
		var offset = 0
		for i in supply_count:
			offset = PI/supply_count*2+offset
			summon_supply_health($you.position + Vector2(sin(offset), cos(offset)) * 50)
		match card_count:
			1:
				end_card_time = 1000
				card_health = 100.0
				$ui/Label.text = "【简单的圆形弹幕】"
				supply_count = 5
				moving = true
			2:
				end_card_time = 1000
				card_health = 100.0
				$ui/Label.text = "【交替的圆形弹幕】"
				supply_count = 0
				moving = true
			3:
				end_card_time = 2000
				card_health = 200.0
				$ui/Label.text = "【蜘蛛网形的弹幕】"
				supply_count = 5
			4:
				end_card_time = 1000
				card_health = 50.0
				$ui/Label.text = "【十字弹】"
				supply_count = 0
			5:
				end_card_time = 2400
				card_health = 200.0
				$ui/Label.text = "【分裂的星星弹幕】"
				supply_count = 5
			6:
				end_card_time = 2400
				card_health = 200.0
				$ui/Label.text = "【RAIN OF STARS】"
				supply_count = 0
			7:
				$you.visible = false
				score += $me.HP * 50 + $me.EP * 10
				var end_scene_instance = end_scene.instance()
				end_scene_instance.string = " Stage Clear！\n\nScore:%d\n\nPress <ENTER> To Retry" % [score]
				get_node("cover").add_child(end_scene_instance)
				paused = true
		if card_count != 7:
			$you.HP = card_health
	match card_count:
		1:
			if moving:
				move_to(Vector2(384,384),3)
			else:
				card_1()
		2:
			if moving:
				move_to(Vector2(384,160),3)
			else:
				card_2()
		3:
			card_3()
		4:
			card_4()
		5:
			card_5()
		6:
			card_6()

func summon_my_bullet():
	var new_me_bullet = pre_me_bullet.instance()
	new_me_bullet.set("position", $me.position + Vector2(0, -22))
	new_me_bullet.velocity = Vector2(0, -2000)
	add_child(new_me_bullet)

func summon_your_bullet():
	var new_you_bullet = pre_you_bullet.instance()
	new_you_bullet.set("position", $you.position)
	add_child(new_you_bullet)
	return get_node(new_you_bullet.name)
	
func summon_your_bomb():
	var new_you_bomb = pre_you_bomb.instance()
	new_you_bomb.set("position", $you.position)
	add_child(new_you_bomb)
	return get_node(new_you_bomb.name)

func summon_your_star():
	var new_you_star = pre_you_star.instance()
	new_you_star.set("position", $you.position)
	add_child(new_you_star)
	return get_node(new_you_star.name)
	
func summon_your_normal_star():
	var new_you_star = pre_you_normal_star.instance()
	new_you_star.set("position", $you.position)
	new_you_star.self_rot = 1
	add_child(new_you_star)
	return get_node(new_you_star.name)
	
func summon_your_purple_star():
	var new_you_star = pre_you_purple_star.instance()
	new_you_star.set("position", $you.position)
	add_child(new_you_star)
	return get_node(new_you_star.name)
	
func summon_your_large_bomb():
	$tan.play()
	var new_you_bomb = pre_you_large_bomb.instance()
	new_you_bomb.set("position", $you.position)
	new_you_bomb.self_rot = 1
	add_child(new_you_bomb)
	return get_node(new_you_bomb.name)

func summon_supply_health(vec:Vector2):
	var new_supply = pre_health.instance()
	new_supply.set("position", vec)
	add_child(new_supply)
	return get_node(new_supply.name)
	
func summon_supply_box(vec:Vector2):
	var new_supply = pre_box.instance()
	new_supply.set("position", vec)
	add_child(new_supply)
	return get_node(new_supply.name)
	
func summon_supply_point(vec:Vector2):
	var new_supply = pre_point.instance()
	new_supply.set("position", vec)
	add_child(new_supply)
	return get_node(new_supply.name)

func check_time_regular(check_time, idx):
	if card_time >= check_card_time[idx] and old_card_time <= check_card_time[idx]:
		check_card_time[idx] += check_time
		return true
	elif card_time >= check_card_time[idx] + check_time:
		check_card_time[idx] += check_time
		return true
	return false
	
func move_to(vec:Vector2, sp:int):
	var velo = vec-$you.position
	velo = (vec-$you.position).normalized()
	$you.translate(velo*sp)
	if velo.dot(vec-$you.position) <= 0:
		moving = false

func card_1():
	if check_time_regular(20, 0):
		var bullet_count = 20
		var speed = 100
		var offset = card_time*0.2
		for i in bullet_count:
			var bullet = summon_your_bullet()
			offset = PI/bullet_count*2+offset
			bullet.velocity = Vector2(cos(offset),sin(offset)) * speed
	if check_time_regular(30, 1):
		var bullet_count = 20
		var speed = 100
		var offset = randf()
		for i in bullet_count:
			var bullet = summon_your_bullet()
			offset = PI/bullet_count*2+offset
			bullet.velocity = Vector2(cos(offset),sin(offset)) * speed

func card_2():
	if check_time_regular(30, 0):
		var bullet_count = 40
		var speed = 100
		var offset = card_time*0.2
		for i in bullet_count:
			var bullet = summon_your_bullet()
			offset = PI/bullet_count*2+offset
			bullet.velocity = Vector2(cos(offset),sin(offset)) * speed
	if check_time_regular(40, 1):
		var bullet_count = 20
		var speed = 200
		var offset = card_time*0.2
		for i in bullet_count:
			var bullet = summon_your_large_bomb()
			offset = PI/bullet_count*2+offset
			bullet.velocity = Vector2(cos(offset),sin(offset)) * speed
			bullet.scale *= 0.7

func card_3():
	if check_time_regular(30, 0):
		var bullet_count = 10
		var speed = 150
		var offset = 0
		for i in bullet_count:
			var bullet = summon_your_bomb()
			offset = PI/bullet_count*2+offset
			bullet.normal_rot = randi()%3 - 1
			bullet.rand_rot = randi()%5 - 2
			bullet.begin_time = min(card_time*0.01, 3)
			bullet.velocity = Vector2(cos(offset),sin(offset)) * (speed - randi()%50)
		speed = 50
		bullet_count = 30
		for i in bullet_count:
			var bullet = summon_your_bomb()
			offset = PI/bullet_count*2+offset
			bullet.velocity = Vector2(cos(offset),sin(offset)) * speed

func card_4():
	if check_time_regular(2, 0):
		if int(card_time)%10 >= 0 and int(card_time)%10 <= 7:
# warning-ignore:unused_variable
			var bullet_count = 40
			var speed = 300
			var offset = randi()
			var tmp_vec = $me.position - $you.position
			if tmp_vec.length() != 0:
				tmp_vec /= tmp_vec.length()
			else:
				tmp_vec = Vector2(cos(offset),sin(offset))
			var bullet1 = summon_your_bullet()
			bullet1.velocity = tmp_vec * speed
			#bullet1.scale *= 0.5
			var bullet2 = summon_your_bullet()
			bullet2.velocity = -tmp_vec * speed
			#bullet2.scale *= 0.5
			var bullet3 = summon_your_bullet()
			tmp_vec = Vector2(-tmp_vec.y, tmp_vec.x)
			bullet3.velocity = tmp_vec * speed
			#bullet3.scale *= 0.5
			var bullet4 = summon_your_bullet()
			bullet4.velocity = -tmp_vec * speed
			#bullet4.scale *= 0.5
	if check_time_regular(80, 1):
		var bullet_count = 40
		var speed = 100
		var offset = card_time*0.2
		for i in bullet_count:
			var bullet = summon_your_bullet()
			offset = PI/bullet_count*2+offset
			bullet.velocity = Vector2(cos(offset),sin(offset)) * speed
	if check_time_regular(100, 2):
		var bullet_count = 20
		var speed = 200
		var offset = card_time*0.2
		for i in bullet_count:
			var bullet = summon_your_bomb()
			offset = PI/bullet_count*2+offset
			bullet.velocity = Vector2(cos(offset),sin(offset)) * speed

func card_5():
	if check_time_regular(300, 0):
		summon_your_star()
	if check_time_regular(30, 1):
		var bullet_count = 40
		var speed = 100
		var offset = card_time*0.2
		for i in bullet_count:
			var bullet = summon_your_normal_star()
			offset = PI/bullet_count*2+offset
			bullet.velocity = Vector2(cos(offset),sin(offset)) * speed

func card_6():
	if check_time_regular(250, 0):
		var bullet = summon_your_star()
		bullet.count = 3
	if check_time_regular(100, 1):
		var bullet_count = 6
		for i in bullet_count:
			var bullet = summon_your_purple_star()
			bullet.set("position",$you.position + Vector2(-200 + 400*i/(bullet_count-1.0), 0))
			bullet.speed = 150
	if check_time_regular(20, 2):
		var speed = 250
		var offset = randi()
		var tmp_vec = $me.position - $you.position
		if tmp_vec.length() != 0:
			tmp_vec /= tmp_vec.length()
		else:
			tmp_vec = Vector2(cos(offset),sin(offset))
		var bullet = summon_your_normal_star()
		bullet.velocity = tmp_vec * speed
