extends KinematicBody2D


export (int) var speed = 80
var velocity = Vector2()


var pauseGui         = preload("Pause.tscn")
var crystalSwordDraw = preload("sprites/swords/crystal_sword.png")
var snakeSwordDraw   = preload("sprites/swords/snake_sword.png")

# bag and components of person 
var bagCurrent = {
	"gold": 1,
	"hpPotion": 5,
}
var PersonStatus = {
	"hp": 50,
	"xp": 0,
	"xpLost": 25, 
	"hpMax": 50,
	"level": 1,
	"sword": {"value": 0, "name": "", "damage": 0},
	"positionX": 100,
	"positionY": 100,
} 

var objectsWorld = {}
var levelsWorld  = {}
var userCurrent =  {}
var userPath = ""

# read data base
var data_bag = File.new()
var data_status = File.new()
var data_objects = File.new()
var data_levels = File.new()
var FibulaPositionPlayer = File.new()
var userCurrent_data = File.new()

#func for acess data base json


#getting path for *json
func get_user_current():
	if userCurrent_data.file_exists("db/userCurrent.json"):
		userCurrent_data.open("db/userCurrent.json", File.READ)
		userCurrent = parse_json(userCurrent_data.get_as_text())
		userCurrent_data.close()
		userPath = str("users/" + userCurrent["userCurrent"] + "/")



func set_position_player_Fibula(positionX, positionY):
	
	FibulaPositionPlayer.open(userPath + "FibulaPositionPlayer.json", File.WRITE)
	FibulaPositionPlayer.store_line(to_json({"positionX": positionX, "positionY": positionY}))
	FibulaPositionPlayer.close()


func get_level_hop():
	if data_levels.file_exists("db/levels.json"):
		data_levels.open("db/levels.json", File.READ)
		levelsWorld = parse_json(data_levels.get_as_text())
		data_levels.close()


func get_objects_world():
	if data_objects.file_exists("db/objects.json"):
		data_objects.open("db/objects.json", File.READ)
		objectsWorld = parse_json(data_objects.get_as_text())
		data_objects.close()


func get_data_Person():
	#status
	if data_status.file_exists(userPath + "MainPersonStatus.json"):      
		data_status.open(userPath + "MainPersonStatus.json", File.READ)  
		PersonStatus = parse_json(data_status.get_as_text())
		data_status.close()

	#bag
	if data_bag.file_exists(userPath + "MainPersonBag.json"):
		data_bag.open(userPath + "MainPersonBag.json", File.READ)
		bagCurrent = parse_json(data_bag.get_as_text())
		data_bag.close()


func set_data_Person():
	data_status.open(userPath + "MainPersonStatus.json", File.WRITE)
	data_bag.open(userPath + "MainPersonBag.json", File.WRITE)
	data_bag.store_line(to_json(bagCurrent))
	data_status.store_line(to_json(PersonStatus))
	data_bag.close()
	data_status.close()


func get_input():
	velocity = Vector2()

		#movements
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
		$AnimatedSprite.play("right")

	elif Input.is_action_pressed("ui_left"):
		velocity.x -= 1
		$AnimatedSprite.play("left")

	elif Input.is_action_pressed("ui_down"):
		velocity.y += 1

		$AnimatedSprite.play("down")

	elif Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		$AnimatedSprite.play("up")
	else:
		$AnimatedSprite.play("idle")



		# objects hotkeys
		
	if Input.is_action_just_pressed("ui_1"):
		if bagCurrent["hpPotion"] >= 1:
			bagCurrent["hpPotion"] -= 1
				
			if PersonStatus["hp"] <= PersonStatus["hpMax"] - objectsWorld["hpPotion"]["quantity"]: 
				PersonStatus["hp"] += objectsWorld["hpPotion"]["quantity"] 
			else:
				PersonStatus["hp"] = PersonStatus["hpMax"]


	if Input.is_action_just_pressed("ui_esc"):
		if not get_tree().paused == true:
			get_tree().paused = true  
			add_child(pauseGui.instance())



	velocity = velocity.normalized() * speed
	velocity = move_and_slide(velocity)  

func _ready():
	
	get_user_current() # getting user first
	get_data_Person() #acess data base 
	#set_data_Person() # if person have not bag and status # esse eu cloquei agora

	get_objects_world() # acess object of world
	get_level_hop()     # acess all levels


func _physics_process(delta):

	get_input()


func _process(delta):

	deathOfPerson()
	
	
	#labels
	$HUD/GoldBar/GoldLabel.text = str(bagCurrent["gold"])
	$HUD/PotionHpBar/PotionLabel.text = str(bagCurrent["hpPotion"])


	# sword labels
	if PersonStatus["sword"]["name"] == "crystalSword":
		$HUD/SwordBar/SwordDraw.set_texture(crystalSwordDraw)
		$HUD/SwordBar/SwordDraw.flip_h = true  
		$HUD/SwordBar/SwordDraw.rect_scale.x = 1
		$HUD/SwordBar/SwordDraw.rect_scale.y = 1

	if PersonStatus["sword"]["name"] == "snakeSword":
		$HUD/SwordBar/SwordDraw.set_texture(snakeSwordDraw) 
		$HUD/SwordBar/SwordDraw.flip_h = true
		$HUD/SwordBar/SwordDraw.rect_scale.x = 1
		$HUD/SwordBar/SwordDraw.rect_scale.y = 1

	# updating hud
	Bars()


# inverse of ready, here is the last action a be done before exit
func _on_MainPerson_tree_exiting():
	set_data_Person()


#buy potions
func _on_life_potion_input_event(viewport, event, shape_idx):
	if Input.is_action_pressed("ui_mouse_right"):
		if bagCurrent["gold"] >= objectsWorld["hpPotion"]["value"]:
			bagCurrent["gold"] -= objectsWorld["hpPotion"]["value"]
			bagCurrent["hpPotion"] += 1


#get swords with guidal
func _on_crystal_sword_input_event(viewport, event, shape_idx):
	if Input.is_action_pressed("ui_mouse_right"):
		if bagCurrent["gold"] >= objectsWorld["crystalSword"]["value"]:
			bagCurrent["gold"] -= objectsWorld["crystalSword"]["value"]
			PersonStatus["sword"] = objectsWorld["crystalSword"]
			#set_data_Person() # not working here
			print('crystal')


func _on_snake_sword_input_event(viewport, event, shape_idx):
	if Input.is_action_pressed("ui_mouse_right"):
		if bagCurrent["gold"] >= objectsWorld["snakeSword"]["value"]:
			bagCurrent["gold"] -= objectsWorld["snakeSword"]["value"]
			PersonStatus["sword"] = objectsWorld["snakeSword"]
			print('snack')



func deathOfPerson():
	
	if PersonStatus["hp"] <= 0:
		
		PersonStatus["xp"] -= PersonStatus["xpLost"]
		if PersonStatus["xp"] < 0:   # for never be -0 of xp 
			PersonStatus["xp"] = 0
		currentLevelPlayer() # for hp max correcty with level current
		
		#here we are modifying positionxY-person in fibuladb 
		set_position_player_Fibula(-43.874062, -34.820889)
		PersonStatus["hp"] = PersonStatus["hpMax"]
		bagCurrent["gold"] = 0
		bagCurrent["hpPotion"] = 0
		get_tree().change_scene("res://Fibula.tscn")


# for life bar and xp bar on hud
func Bars():
	
	$HUD/ProgressBarLifePerson.max_value = PersonStatus["hpMax"]
	$HUD/ProgressBarLifePerson.value = PersonStatus["hp"]
	
	$HUD/ProgressBarLifeHUD.max_value = PersonStatus["hpMax"]
	$HUD/ProgressBarLifeHUD.value = PersonStatus["hp"]
	
	$HUD/ProgressBarLifeHUDLabel.text = str(PersonStatus["hp"]) + "/" + str(PersonStatus["hpMax"])

	
	$HUD/ProgressBarXp.max_value = levelsWorld[str(PersonStatus["level"])]["end"]
	$HUD/ProgressBarXp.min_value = levelsWorld[str(PersonStatus["level"])]["start"]
	$HUD/ProgressBarXp.value = PersonStatus["xp"]
	$HUD/ProgressBarXpLabel.text = "Lv." + str(PersonStatus["level"]) +  " ( xp. " + str(PersonStatus["xp"]) + " )"


#level player verify
func currentLevelPlayer():
	for x in range(2 , levelsWorld["limitLevel"]+1): # verificando do 2 pq o 1 ja tem o default 
		# aqui só é verificado se tiver dentro do range do xp, ou seja quando for maior e o perso passar
		# de fase, esse if nao entra
		if PersonStatus["xp"] >= levelsWorld[str(x)]["start"] and PersonStatus["xp"] <= levelsWorld[str(x)]["end"]:
			PersonStatus["level"] = x
			PersonStatus["hpMax"] =  50 * x
			PersonStatus["xpLost"] = 25 * x


# full life when level up
func setLifeWithLevelUp():
	if PersonStatus["xp"] > levelsWorld[str(PersonStatus["level"])]["end"]:
		PersonStatus["hp"] = PersonStatus["hpMax"] + 50


