class_name CellSpawner
extends Node

@export var cell_scene : PackedScene
@export var nb_cells : int = 10
@export var cell_controller : Script

func spawn():
	for i in nb_cells:
		var c = cell_scene.instantiate() as Cell
		c.name = "Cell_%d" % i
		add_child(c)
		c.set_controller(cell_controller.new() as Controller)
		randomize()

		c.position.x = randi_range(-2000, 2000)
		c.position.y = randi_range(-2000, 2000)
