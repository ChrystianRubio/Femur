extends KinematicBody2D


export (int) var speed = 80
var velocity = Vector2()

var crystalSwordDraw = preload("res://sprites/swords/crystal_sword.png")
var snackSwordDraw   = preload("res://sprites/swords/snake_sword.png")

# bag and components of person 
var bagCurrent = {
	"gold": 1,
	"hpPotion": 0
}
var PersonStatus = {
	"hp": 100,
	"xp": 0,
	"xpLost": 25, 
	"hpMax": 100,
	"level": 1,
	"sword": {"value": 0, "name": "", "damage": 0},
	"positionX": 100,
	"positionY": 100,
} 

var objectsWorld = {}
var levelsWorld  = {}


# read data base
var data_bag = File.new()
var data_status = File.new()
var data_objects = File.new()
var data_levels = File.new()
var FibulaPositionPlayer = File.new()


#func for acess data base json

func set_position_player_Fibula(positionX, positionY):
	
	FibulaPositionPlayer.open("res://FibulaPositionPlayer.json", File.WRITE)
	FibulaPositionPlayer.store_line(to_json({"positionX": positionX, "positionY": positionY}))
	FibulaPositionPlayer.close()


func get_level_hop():
	if data_levels.file_exists("res://levels.json"):
		data_levels.open("res://levels.json", File.READ)
		levelsWorld = parse_json(data_levels.get_as_text())
		data_levels.close()


func get_objects_world():
	if data_objects.file_exists("res://objects.json"):
		data_objects.open("res://objects.json", File.READ)
		objectsWorld = parse_json(data_objects.get_as_text())
		data_objects.close()


func get_data_Person():
	if data_status.file_exists("res://MainPersonStatus.json"):
		data_status.open("res://MainPersonStatus.json", File.READ)
		PersonStatus = parse_json(data_status.get_as_text())
		data_status.close()
		
	if data_bag.file_exists("res://MainPersonBag.json"):
		data_bag.open("res://MainPersonBag.json", File.READ)
		bagCurrent = parse_json(data_bag.get_as_text())
		data_bag.close()


func set_data_Person():
	data_status.open("res://MainPersonStatus.json", File.WRITE)
	data_bag.open("res://MainPersonBag.json", File.WRITE)
	data_bag.store_line(to_json(bagCurrent))
	data_status.store_line(to_json(PersonStatus))
	data_bag.close()
	data_status.close()


func get_input():
	velocity = Vector2()


		#movements
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1

	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1

	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
		$AnimatedSprite.play("down")

	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		$AnimatedSprite.play("up")

		# objects hotkeys
		
	if Input.is_action_just_pressed("ui_1"):
		if bagCurrent["hpPotion"] >= 1:
			bagCurrent["hpPotion"] -= 1
				
			if PersonStatus["hp"] < PersonStatus["hpMax"]: 
				PersonStatus["hp"] += objectsWorld["hpPotion"]["quantity"] 
			set_data_Person()

	velocity = velocity.normalized() * speed


func _ready():
	get_data_Person() #acess data base first
	get_objects_world()
	get_level_hop()


func _physics_process(delta):

	get_input()
	velocity = move_and_slide(velocity)


func _process(delta):
	
	deathOfPerson()
	
	
	#labels
	if PersonStatus["hp"] >= 100:
		$HpBar/HpLabel.modulate = "#ffffff"
	elif PersonStatus["hp"] < 100 and PersonStatus["hp"] >= 50:
		$HpBar/HpLabel.modulate = "#ffff00"
	else:
		$HpBar/HpLabel.modulate = "#ff0000"

	$HpBar/HpLabel.text = str(PersonStatus["hp"])
	$GoldBar/GoldLabel.text = str(bagCurrent["gold"])
	$PotionHpBar/PotionLabel.text = str(bagCurrent["hpPotion"])
	$LevelBar/LevelLabel.text = str(PersonStatus["level"])
	$XpBar/XpLabel.text = str(PersonStatus["xp"])
	
	# sword label
	if PersonStatus["sword"]["name"] == "crystalSword":
		$SwordBar/SwordDraw.set_texture(crystalSwordDraw)
		$SwordBar/SwordDraw.flip_h = true  
		$SwordBar/SwordDraw.scale.x = 1
		$SwordBar/SwordDraw.scale.y = 1

	if PersonStatus["sword"]["name"] == "snackSword":
		$SwordBar/SwordDraw.set_texture(snackSwordDraw) 
		$SwordBar/SwordDraw.flip_h = true
		$SwordBar/SwordDraw.scale.x = 1
		$SwordBar/SwordDraw.scale.y = 1


	get_data_Person() 
	getPositionPlayer()
	currentLevelPlayer()


# inverse of ready, here is the last action a be done before exit
func _on_MainPerson_tree_exiting():
	set_data_Person()


#buy potions
func _on_life_potion_input_event(viewport, event, shape_idx):
	if Input.is_action_pressed("ui_mouse_right"):
		if bagCurrent["gold"] >= objectsWorld["hpPotion"]["value"]:
			bagCurrent["gold"] -= objectsWorld["hpPotion"]["value"]
			bagCurrent["hpPotion"] += 1
		set_data_Person()


#get swords with guidal
func _on_crystal_sword_input_event(viewport, event, shape_idx):
	if Input.is_action_pressed("ui_mouse_right"):
		if bagCurrent["gold"] >= objectsWorld["crystalSword"]["value"]:
			bagCurrent["gold"] -= objectsWorld["crystalSword"]["value"]
			PersonStatus["sword"] = objectsWorld["crystalSword"]
		set_data_Person()


func _on_snake_sword_input_event(viewport, event, shape_idx):
	if Input.is_action_pressed("ui_mouse_right"):
		if bagCurrent["gold"] >= objectsWorld["snackSword"]["value"]:
			bagCurrent["gold"] -= objectsWorld["snackSword"]["value"]
			PersonStatus["sword"] = objectsWorld["snackSword"]
		set_data_Person()


# get position x and y of person and setting in db person
func getPositionPlayer():			# after change name of function foe setPositionPlayer
	PersonStatus["positionX"] = position.x
	PersonStatus["positionY"] = position.y

	set_data_Person()


func deathOfPerson():
	# death of person
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
		set_data_Person()  # this is soo imporant
		get_tree().change_scene("res://Fibula.tscn")


#level player verify
func currentLevelPlayer():
	if PersonStatus["xp"] >= levelsWorld["1"]["start"] and PersonStatus["xp"] <= levelsWorld["1"]["end"]:
		PersonStatus["level"] = 1
		PersonStatus["hpMax"] = 100
		PersonStatus["xpLost"] = 25
	elif PersonStatus["xp"] >= levelsWorld["2"]["start"] and PersonStatus["xp"] <= levelsWorld["2"]["end"]:
		PersonStatus["level"] = 2
		PersonStatus["hpMax"] = 150
		PersonStatus["xpLost"] = 50
	elif PersonStatus["xp"] >= levelsWorld["3"]["start"] and PersonStatus["xp"] <= levelsWorld["3"]["end"]:
		PersonStatus["level"] = 3
		PersonStatus["hpMax"] = 200
		PersonStatus["xpLost"] = 100
	elif PersonStatus["xp"] >= levelsWorld["4"]["start"] and PersonStatus["xp"] <= levelsWorld["4"]["end"]:
		PersonStatus["level"] = 4
		PersonStatus["hpMax"] = 240
		PersonStatus["xpLost"] = 150
	elif PersonStatus["xp"] >= levelsWorld["5"]["start"] and PersonStatus["xp"] <= levelsWorld["5"]["end"]:
		PersonStatus["level"] = 5
		PersonStatus["hpMax"] = 280
		PersonStatus["xpLost"] = 200
	elif PersonStatus["xp"] >= levelsWorld["6"]["start"] and PersonStatus["xp"] <= levelsWorld["6"]["end"]:
		PersonStatus["level"] = 6
		PersonStatus["hpMax"] = 310
		PersonStatus["xpLost"] = 250
	elif PersonStatus["xp"] >= levelsWorld["7"]["start"] and PersonStatus["xp"] <= levelsWorld["7"]["end"]:
		PersonStatus["level"] = 7
		PersonStatus["hpMax"] = 340
		PersonStatus["xpLost"] = 300
	elif PersonStatus["xp"] >= levelsWorld["8"]["start"] and PersonStatus["xp"] <= levelsWorld["8"]["end"]:
		PersonStatus["level"] = 8
		PersonStatus["hpMax"] = 360
		PersonStatus["xpLost"] = 350
	elif PersonStatus["xp"] >= levelsWorld["9"]["start"] and PersonStatus["xp"] <= levelsWorld["9"]["end"]:
		PersonStatus["level"] = 9
		PersonStatus["hpMax"] = 380
		PersonStatus["xpLost"] = 400
	elif PersonStatus["xp"] >= levelsWorld["10"]["start"] and PersonStatus["xp"] <= levelsWorld["10"]["end"]:
		PersonStatus["level"] = 10
		PersonStatus["hpMax"] = 400
		PersonStatus["xpLost"] = 450
