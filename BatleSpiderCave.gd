extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var read_file = File.new()
var nomes = {
	"chrys": [12, 3400],
	"rafale": [77, 100],
	"mouses": {
		"lg": 400,
	}
}
# Called when the node enters the scene tree for the first time.
func _ready():
	read_file.open("res://teste.json", File.WRITE)
	read_file.store_line(to_json(nomes))
	read_file.close()
	
	read_file.open("res://objects.json", File.READ)
	var read_true = parse_json(read_file.get_as_text())
	
	print(read_true["potion"])
	#print(readTrue["hpPotion"])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
