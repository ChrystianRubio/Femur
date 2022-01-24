extends KinematicBody2D

export (int) var hp = 15
export (float) var speed = 0.2


var damageSpider = 3
var xpSpider = 3
var lootSpiderFull = ["gold", "hpPotion"]
var lootSpider = ""


# variable for data read and write
var data_statusPerson = File.new()
var PersonStatus = {}
var	data_bagPerson = File.new()
var bagCurrentPerson = {}


#func for acess data base json
func get_data_Person():
	data_statusPerson.open("res://MainPersonStatus.json", File.READ)
	data_bagPerson.open("res://MainPersonBag.json", File.READ)
	bagCurrentPerson = parse_json(data_bagPerson.get_as_text())
	PersonStatus = parse_json(data_statusPerson.get_as_text())
	data_bagPerson.close()
	data_statusPerson.close()


func set_data_Person():
	data_statusPerson.open("res://MainPersonStatus.json", File.WRITE)
	data_bagPerson.open("res://MainPersonBag.json", File.WRITE)
	data_bagPerson.store_line(to_json(bagCurrentPerson))
	data_statusPerson.store_line(to_json(PersonStatus))
	
	data_bagPerson.close()
	data_statusPerson.close()


#  the scene tree for the first time.
func _ready():

	get_data_Person()
	FollowPlayerNewType()
	randomize() # to the rand_range work
	set_process(true)  # to the rand_range work
	
	position.y = rand_range(-10, 130) 
	position.x = rand_range(5, 240)  


#func _physics_process(delta):
	#velocity = Vector2()
	#velocity = velocity.normalized() * speed
#	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_data_Person()
	FollowPlayerNewType()
	
	
	if hp <= 0:
		$AnimatedSprite.visible = false
		$death_sprite.visible = true
		$CollisionShape2D.disabled = true
		
		# for collision more correty in death sprite
		$FollowPlayer/CollisionShape2D.scale.x = 0.3
		$FollowPlayer/CollisionShape2D.scale.y = 0.3


# right clique on enemy to fight
func _on_Spider_input_event(viewport, event, shape_idx):
	possibilityDamage(70)


# 10 sec for the death body "desappier"
func _on_Timer_timeout():
	if self.hp <= 0:
		queue_free()


func _on_FollowPlayer_body_entered(body):
	
	# here loot of spider go to the person bag dictionary, when he walk on the death spider
	if hp <= 0 and body.name == "MainPerson":

		possibilityLoot(10, 65, bagCurrentPerson)
		
		#set xp of person
		PersonStatus["xp"] += xpSpider
		
		queue_free()  #queue free for delete this spider, if the person not get the loot in 10 sec
					  # the death body will desappier


		#NO MORE USED !!!
#func _on_FollowPlayer_body_exited(body):
#	pass

# possibility the person get damage
#func _on_FollowPlayer_input_event(viewport, event, shape_idx):
	#possibilityDamage(100)
#	pass
	


#func for damage spider in person possibility and always person does damage in spider
func possibilityDamage(percent: int):
	var possibility = rand_range(1, 100)
	if self.hp >= 1:
		if Input.is_action_pressed("ui_mouse_right"):
			# damage player in spider
			self.hp -= PersonStatus["sword"]["damage"]
			if possibility <= percent:
				#damageSpider = 3
				PersonStatus["hp"] -= damageSpider

		set_data_Person()


#func for loot spider in person possibility
# here is not necessary set in db because we have _on_Spider_tree_exiting in the same time
func possibilityLoot(percentPotion: int, percentGold, person):
	var possibility = rand_range(1, 100)
	print('possibilidade de loot:' , possibility)
	if possibility <= percentPotion:
		person["hpPotion"] += int(rand_range(1, 1))
		print('ganhou potion')
	if possibility <= percentGold:
		person["gold"] += int(rand_range(1, 2))
		print('ganhou gold')


func FollowPlayerNewType():
	#spider with person
	#here we need 4 or 6 sprite for the simple animation
	if hp >= 1 :
		#right up
		if position.x <= PersonStatus["positionX"] and position.y >= PersonStatus["positionY"]:
			position.x += speed
			position.y -= speed
			#$AnimatedSprite.flip_h = true
			$AnimatedSprite.rotation_degrees = +20
		#left up
		elif position.x >= PersonStatus["positionX"] and position.y >= PersonStatus["positionY"]:
			position.x -= speed
			position.y -= speed
			#$AnimatedSprite.flip_h = false
			$AnimatedSprite.rotation_degrees = -20
		#right down
		elif position.x <= PersonStatus["positionX"] and position.y <= PersonStatus["positionY"]:
			position.x += speed
			position.y += speed
			#$AnimatedSprite.flip_h = true
			$AnimatedSprite.rotation_degrees = 146
		#left down
		elif position.x >= PersonStatus["positionX"] and position.y <= PersonStatus["positionY"]:
			position.x -= speed
			position.y += speed
			#$AnimatedSprite.flip_h = false
			$AnimatedSprite.rotation_degrees = -146


# inverse ready, the last action in current tree
func _on_Spider_tree_exiting():
	set_data_Person()
