extends Node2D


const spaw_spider = preload("res://Spider.tscn")


#spaw of spider in sec
func _on_spaw_timeout():
	for i in range(rand_range(1, 4)):
		add_child(spaw_spider.instance())


#init spaw of spider
func _on_spaw_init_timeout():
	for i in range(rand_range(0, 6)):
		add_child(spaw_spider.instance())


#hole for back Fibula
func _on_Area2D_body_entered(body):
	if body.name == "MainPerson":
		get_tree().change_scene("res://Fibula.tscn")
