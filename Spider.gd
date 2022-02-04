extends KinematicBody2D

export (int) var hp = 15
export (float) var speed = 0.2
var walk = Vector2()


var damageSpider = 3
var xpSpider = 3
var lootSpiderFull = ["gold", "hpPotion"]
var lootSpider = ""


#  the scene tree for the first time.
func _ready():

	
	FollowPlayerNewType()  # follow player


	randomize() # to the rand_range work

	# random spaw
	position.y = rand_range(-10, 130) 
	position.x = rand_range(5, 240)  


#func _physics_process(delta):
#	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	FollowPlayerNewType() # follow player


	if hp <= 0:
		$AnimatedSprite.visible = false
		$death_sprite.visible = true
		$death_sprite.play("death")
		$CollisionShape2D.disabled = true
		show_behind_parent = true


# right clique on enemy to fight
func _on_Spider_input_event(viewport, event, shape_idx):
	possibilityDamage(70)
	#starting the timer for desappier death body
	if self.hp < 0:
		$death_spider_timer.start()


# 10 sec for the death body "desappier"
func _on_death_spider_timer_timeout():
	if self.hp <= 0:
		$death_spider_timer.stop()
		queue_free()


func _on_FollowPlayer_body_entered(body):
	# here loot of spider go to the person bag dictionary, when he walk on the death spider
	if hp <= 0 and body.name == "MainPerson":

		possibilityLoot(5, 65, get_parent().get_node("MainPerson").bagCurrent)
		
		#set xp of person
		get_parent().get_node("MainPerson").PersonStatus["xp"] += xpSpider
		get_parent().get_node("MainPerson").setLifeWithLevelUp()
		get_parent().get_node("MainPerson").currentLevelPlayer()
	
		queue_free()  #queue free for delete this spider, if the person not get the loot in 10 sec
					  # the death body will desappier


#func for damage spider in person possibility and always person does damage in spider
func possibilityDamage(percent: int):
	var possibility = rand_range(1, 100)
	if self.hp >= 1:
		if Input.is_action_pressed("ui_mouse_right"):
			# damage player in spider
			self.hp -= get_parent().get_node("MainPerson").PersonStatus["sword"]["damage"]
			if possibility <= percent:
				get_parent().get_node("MainPerson").PersonStatus["hp"] -= damageSpider


#for possibility spider loot 
func possibilityLoot(percentPotion: int, percentGold, person):
	var possibility = rand_range(1, 100)
	
	if possibility <= percentPotion:
		get_parent().get_node("MainPerson").bagCurrent["hpPotion"] += int(rand_range(1, 1))

	if possibility <= percentGold:
		get_parent().get_node("MainPerson").bagCurrent["gold"] += int(rand_range(1, 2))


func FollowPlayerNewType():
	walk = Vector2()
  
	#spider with person
	if hp >= 1 :
		#right up
		if position.x < get_parent().get_node("MainPerson").position.x and position.y > get_parent().get_node("MainPerson").position.y:
			position.x += speed
			position.y -= speed
			#rotation_degrees = -115
			$AnimatedSprite.play("right")

		#left up
		elif position.x > get_parent().get_node("MainPerson").position.x and position.y > get_parent().get_node("MainPerson").position.y:
			position.x -= speed
			position.y -= speed
			#rotation_degrees = 168
			$AnimatedSprite.play("left")

		#right down
		elif position.x < get_parent().get_node("MainPerson").position.x and position.y < get_parent().get_node("MainPerson").position.y:
			position.x += speed
			position.y += speed
			#rotation_degrees = 0
			$AnimatedSprite.play("right")

		#left down
		elif position.x > get_parent().get_node("MainPerson").position.x and position.y < get_parent().get_node("MainPerson").position.y:
			position.x -= speed
			position.y += speed
			#rotation_degrees = 65
			$AnimatedSprite.play("left")

		walk = walk.normalized() * speed
		walk = move_and_slide(walk)


# inverse ready, the last action in current tree
#func _on_Spider_tree_exiting():
	#set_data_Person()
#	pass


func _on_Spider_tree_entered():
# toda vez que algo entrar na tree, tem que fazer behind
# para que todos os death spider fiquem atras dos outros
# independente se nasceu primeiro ou nao
	if hp <= 0:
		show_behind_parent = true
		$death_sprite.show_behind_parent = true
	else:
		$AnimatedSprite.show_behind_parent = true
