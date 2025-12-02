class_name CellSpawner
extends Node

@export var cell_scene : PackedScene
@export var nb_cells : int = 25
@export var cell_controller : Script

var object_pool := []

var square_range : float = 1500.0

func spawn():
	for i in nb_cells:
		var c = cell_scene.instantiate() as Cell
		object_pool.append(c)
		c.name = "Cell_%d" % i
		c.set_label(c.name)
		add_child(c)
		c.set_controller(cell_controller.new() as Controller)
		randomize()
		c.get_sprite().modulate = Color(randf(), randf(), randf())

		c.position.x = randi_range(-square_range, square_range)
		c.position.y = randi_range(-square_range, square_range)

		# Check to avoid overlapping at spawn
		if (i > 0):
			var overlapping := true
			while overlapping:
				overlapping = false
				for other_cell in object_pool:
					if other_cell != c:
						if c.position.distance_to(other_cell.position) < (c.get_size() + other_cell.get_size()):
							overlapping = true
							c.position.x = randi_range(-square_range, square_range)
							c.position.y = randi_range(-square_range, square_range)
							break

func get_pool() -> Array:
	return object_pool