extends Node2D


const spaw_spider = preload("res://Spider.tscn")


# Called when the node enters the scene tree for the first time.
				# NOT USED YET
#func _ready():
	#randomize() # to the rand_range work
	#set_process(true)  # to the rand_range work
#	pass


#spaw of spider in sec
func _on_spaw_timeout():
	for i in range(rand_range(0, 3)):
		add_child(spaw_spider.instance())


#init spaw of spider
func _on_spaw_init_timeout():
	for i in range(rand_range(0, 6)):
		add_child(spaw_spider.instance())


#hole for back Fibula
func _on_Area2D_body_entered(body):
	if body.name == "MainPerson":
		get_tree().change_scene("res://Fibula.tscn")
