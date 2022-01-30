extends Node2D

var userPath = ""

var userCurrent = ""
var userCurrent_data =  File.new()
var get_position_data = File.new()


func get_last_position_player():

	
		# getting user_path
	if userCurrent_data.file_exists("db/userCurrent.json"):
		userCurrent_data.open("db/userCurrent.json", File.READ)
		userCurrent = parse_json(userCurrent_data.get_as_text())
		userCurrent_data.close()
		userPath = str("users/" + userCurrent["userCurrent"] + "/")

	if get_position_data.file_exists(userPath + "FibulaPositionPlayer.json"):
		get_position_data.open(userPath + "FibulaPositionPlayer.json", File.READ)
		var get_position_current = parse_json(get_position_data.get_as_text())
		get_position_data.close()
		$MainPerson.position.x = get_position_current["positionX"]
		$MainPerson.position.y = get_position_current["positionY"]
	else:  #for the first time position
		$MainPerson.position.x = -43.874062
		$MainPerson.position.y = -34.820889
		set_last_position_player()


func set_last_position_player():
	var get_position_data = File.new()
	get_position_data.open(userPath + "FibulaPositionPlayer.json", File.WRITE)
	var last_position = {"positionX": $MainPerson.position.x, "positionY": $MainPerson.position.y+14}
	get_position_data.store_line(to_json(last_position))
	get_position_data.close()


# for the first time.
func _ready():
	get_last_position_player()


#	set_last_position_player()
func _on_Fibula_tree_exiting():
	set_last_position_player()
