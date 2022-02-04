extends KinematicBody2D


export (int) var hp = 30
export (float) var speed = 0.20

var damageTroll = 7
var xpTroll = 25
var walk = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() # to the rand_range work

	#for random position
	position.y = rand_range(-10, 130)
	position.x = rand_range(5, 240)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	FollowPlayerNewType()
	
	if self.hp <= 0:
		$CollisionShape2D.disabled = true
		show_behind_parent = true
		$AnimatedSprite.play("death")


#right click to person to do damage in troll, with collisionshape2d of Troll for be more correcty pointer mouse
func _on_Troll_input_event(viewport, event, shape_idx):
	possibilityDamage(55)
	
	#starting the timer for desappier death body
	if self.hp <= 0:
		$death_troll_timer.start()


func _on_death_troll_timer_timeout():
	if self.hp <= 0:
		$death_troll_timer.stop()
		queue_free()


# this func is for follow the person
func _on_FollowPlayer_body_entered(body):
	
	# here loot of troll go to the person bag dictionary, when he walk on the death troll
	if hp <= 0 and body.name == "MainPerson":
		
		possibilityLoot(10, 45, get_parent().get_node("MainPerson").bagCurrent)
		get_parent().get_node("MainPerson").PersonStatus["xp"] += xpTroll
		get_parent().get_node("MainPerson").setLifeWithLevelUp() # for full life when level up
		get_parent().get_node("MainPerson").currentLevelPlayer()

		queue_free()  #queue free for delete this troll, if the person not get the loot in 10 sec
					  # the death body will desappier


#func for possibility attack troll and person always does damage in troll
func possibilityDamage(percent: int):
	var possibility = rand_range(1, 100)
	if self.hp >= 1:
		if Input.is_action_just_pressed("ui_mouse_right"):
			# player damage in troll
			self.hp -= get_parent().get_node("MainPerson").PersonStatus["sword"]["damage"] # getting damage of player/sword in db
			# possibility of troll make damage in player
			if possibility <= percent:
				get_parent().get_node("MainPerson").PersonStatus["hp"] -= damageTroll


#func for possibility loot troll
func possibilityLoot(percentPotion: int, percentGold: int, person):
	var possibility = rand_range(1, 100)
	
	if possibility <= percentPotion:
		person["hpPotion"] += int(rand_range(1, 2))

	if possibility <= percentGold:
		person["gold"] += int(rand_range(1, 7))


# troll follow player
func FollowPlayerNewType():
	
	walk = Vector2()
	#here we need 4 or 6 sprite for the simple animation
	if hp >= 1 :
		#right up
		if position.x < get_parent().get_node("MainPerson").position.x and position.y > get_parent().get_node("MainPerson").position.y:
			position.x += speed
			position.y -= speed
			#$AnimatedSprite.flip_h = true
			$AnimatedSprite.play("right")
			rotation_degrees = -20

		#left up
		elif position.x > get_parent().get_node("MainPerson").position.x and position.y > get_parent().get_node("MainPerson").position.y:
			position.x -= speed
			position.y -= speed
			#$AnimatedSprite.flip_h = false
			$AnimatedSprite.play("left")
			rotation_degrees = +20

		#right down
		elif position.x < get_parent().get_node("MainPerson").position.x and position.y < get_parent().get_node("MainPerson").position.y:
			position.x += speed
			position.y += speed
			#$AnimatedSprite.flip_h = true
			$AnimatedSprite.play("right")
			rotation_degrees = +20

		#left down
		elif position.x > get_parent().get_node("MainPerson").position.x and position.y < get_parent().get_node("MainPerson").position.y:
			position.x -= speed
			position.y += speed
			#$AnimatedSprite.flip_h = false
			$AnimatedSprite.play("left")
			rotation_degrees = -20

		walk = walk.normalized() * speed
		walk = move_and_slide(walk)


# for all death spider be behind than other
func _on_Troll_tree_entered():
	if self.hp <= 0:
		show_behind_parent = true
		$death_sprite.show_behind_parent = true
	else:
		$AnimatedSprite.show_behind_parent = true
