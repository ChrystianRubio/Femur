extends Node2D


func get_last_position_player():
	var get_position_data = File.new()
	get_position_data.open("res://FibulaPositionPlayer.json", File.READ)
	var get_position_current = parse_json(get_position_data.get_as_text())
	get_position_data.close()
	$MainPerson.position.x = get_position_current["positionX"]
	$MainPerson.position.y = get_position_current["positionY"]

func set_last_position_player():
	var get_position_data = File.new()
	get_position_data.open("res://FibulaPositionPlayer.json", File.WRITE)
	var last_position = {"positionX": $MainPerson.position.x, "positionY": $MainPerson.position.y+14}
	get_position_data.store_line(to_json(last_position))
	get_position_data.close()


# Called when the node enters the scene tree for the first time.
func _ready():
	get_last_position_player()


#	set_last_position_player()
func _on_Fibula_tree_exiting():
	set_last_position_player()
