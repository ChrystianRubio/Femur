extends Area2D


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


func _on_HoleSpider_body_entered(body):
	if body.name == "MainPerson":
		get_tree().change_scene("SpiderCave1.tscn")

