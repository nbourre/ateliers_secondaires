extends Node2D

@export var food : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 100:
		var f = food.instantiate()
		add_child(f)
		randomize()
		f.position.x = randi_range(-2000, 2000)
		f.position.y = randi_range(-2000, 2000)


