extends Control

# Called when the node enters the scene tree for the first time.
#func _ready():
	

func _process(delta):
	if Input.is_action_just_pressed("ui_enter"):
		_on_Continue_button_down()

func _on_Continue_button_down():
	get_tree().paused = false
	queue_free()

func _on_quit_button_down():
	get_tree().paused = false
	get_tree().change_scene("res://Menu.tscn")
