extends Node2D

const spaw_troll = preload("res://Troll.tscn")


#spaw troll in sec
func _on_spaw_timeout():
	for i in range(rand_range(1, 3)):
		add_child(spaw_troll.instance())


func _on_Area2D_body_entered(body):
	if body.name == "MainPerson":
		get_tree().change_scene("res://Fibula.tscn")


func _on_spaw_init_timeout():
	for i in range(rand_range(1, 3)):
		add_child(spaw_troll.instance())
