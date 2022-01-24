extends KinematicBody2D


export (int) var hp = 30
export (float) var speed = 0.20

var damageTroll = 7
var xpTroll = 25


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


# Called when the node enters the scene tree for the first time.
func _ready():
	#pass # Replace with function body.
	randomize() # to the rand_range work
	set_process(true)  # to the rand_range work
	
	position.y = rand_range(-10, 130)
	position.x = rand_range(5, 240)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_data_Person()
	FollowPlayerNewType()
	
	if hp <= 0:
		$CollisionShape2D.disabled = true
		$AnimatedSprite.visible = false
		$death_sprite.visible = true
		
		# for collision more correty in death sprite
		$FollowPlayer/CollisionShape2D.scale.x = 0.3
		$FollowPlayer/CollisionShape2D.scale.y = 0.3


#right click to person to do damage in troll, with collisionshape2d of Troll for be more correcty pointer mouse
func _on_Troll_input_event(viewport, event, shape_idx):
	possibilityDamage(55)


func _on_Timer_timeout():
	if hp <= 0:
		queue_free()


# this func is for follow the person
func _on_FollowPlayer_body_entered(body):
	
	# here loot of troll go to the person bag dictionary, when he walk on the death troll
	if hp <= 0 and body.name == "MainPerson":
		
		possibilityLoot(30, 45, bagCurrentPerson)

		#set xp of person
		PersonStatus["xp"] += xpTroll
		
		queue_free()  #queue free for delete this troll, if the person not get the loot in 10 sec
					  # the death body will desappier


#func for possibility attack troll and person always does damage in troll
func possibilityDamage(percent: int):
	var possibility = rand_range(1, 100)
	if self.hp >= 1:
		if Input.is_action_pressed("ui_mouse_right"):
			# possibility of our person make damage in troll
			self.hp -= PersonStatus["sword"]["damage"] # getting damage of player/sword in db
			# possibility of troll make damage in our person
			if possibility <= percent:
				PersonStatus["hp"] -= damageTroll
				set_data_Person()


#func for possibility loot troll
func possibilityLoot(percentPotion: int, percentGold: int, person):
	var possibility = rand_range(1, 100)
	print('possibilidade de loot:' , int(possibility))
	if possibility <= percentPotion:
		person["hpPotion"] += int(rand_range(1, 2))
		print('ganhou potion')
	if possibility <= percentGold:
		person["gold"] += int(rand_range(1, 7))
		print('ganhou gold')


# troll follow player
func FollowPlayerNewType():
	#here we need 4 or 6 sprite for the simple animation
	if hp >= 1 :
		#right up
		if position.x < PersonStatus["positionX"] and position.y > PersonStatus["positionY"]:
			position.x += speed
			position.y -= speed
			$AnimatedSprite.flip_h = true
			$AnimatedSprite.rotation_degrees = -20
		#left up
		elif position.x > PersonStatus["positionX"] and position.y > PersonStatus["positionY"]:
			position.x -= speed
			position.y -= speed
			$AnimatedSprite.flip_h = false
			$AnimatedSprite.rotation_degrees = +20
		#right down
		elif position.x < PersonStatus["positionX"] and position.y < PersonStatus["positionY"]:
			position.x += speed
			position.y += speed
			$AnimatedSprite.flip_h = true
			$AnimatedSprite.rotation_degrees = +20
		#left down
		elif position.x > PersonStatus["positionX"] and position.y < PersonStatus["positionY"]:
			position.x -= speed
			position.y += speed
			$AnimatedSprite.flip_h = false
			$AnimatedSprite.rotation_degrees = -20


func _on_Troll_tree_exiting():
	set_data_Person()
