class_name CellSpawner
extends Node

@export var cell_scene : PackedScene
@export var nb_cells : int = 25
@export var cell_controller : Script

var object_pool := []
var no_spawn_areas : Array[Dictionary] = []  # Array of {position: Vector2, radius: float}

var square_range : float = 1500.0

func set_no_spawn_areas(areas: Array[Dictionary]) -> void:
	no_spawn_areas = areas

func is_position_valid(pos: Vector2) -> bool:
	for area in no_spawn_areas:
		if pos.distance_to(area.position) < area.radius:
			return false
	return true

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

		# Check to avoid overlapping at spawn and respect no-spawn areas
		if (i > 0):
			var overlapping := true
			while overlapping:
				overlapping = false
				
				# Check no-spawn areas
				if not is_position_valid(c.position):
					overlapping = true
					c.position.x = randi_range(-square_range, square_range)
					c.position.y = randi_range(-square_range, square_range)
					continue
				
				# Check other cells
				for other_cell in object_pool:
					if other_cell != c:
						if c.position.distance_to(other_cell.position) < (c.get_size() + other_cell.get_size()):
							overlapping = true
							c.position.x = randi_range(-square_range, square_range)
							c.position.y = randi_range(-square_range, square_range)
							break

func get_pool() -> Array:
	return object_pool