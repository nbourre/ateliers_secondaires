class_name GenerateurCellule
extends Node

@export var scene_cellule : PackedScene
@export var nb_cellules : int = 25
@export var controleur_cellule : Script

var object_pool := []
var no_spawn_areas : Array[Dictionary] = []  # Array of {position: Vector2, radius: float}

var dimension_terrain : float = 1500.0

func set_no_spawn_areas(areas: Array[Dictionary]) -> void:
	no_spawn_areas = areas

func is_position_valid(pos: Vector2) -> bool:
	for area in no_spawn_areas:
		if pos.distance_to(area.position) < area.radius:
			return false
	return true

func spawn():
	for i in nb_cellules:
		var c = scene_cellule.instantiate() as Cellule
		object_pool.append(c)
		c.name = "Cell_%d" % i
		c.set_label(c.name)
		add_child(c)
		c.set_controller(controleur_cellule.new() as Controleur)
		randomize()
		c.get_sprite().modulate = Color(randf(), randf(), randf())

		c.position.x = randi_range(-dimension_terrain, dimension_terrain)
		c.position.y = randi_range(-dimension_terrain, dimension_terrain)

		# Check to avoid overlapping at spawn and respect no-spawn areas
		if (i > 0):
			var overlapping := true
			while overlapping:
				overlapping = false
				
				# Check no-spawn areas
				if not is_position_valid(c.position):
					overlapping = true
					c.position.x = randi_range(-dimension_terrain, dimension_terrain)
					c.position.y = randi_range(-dimension_terrain, dimension_terrain)
					continue
				
				# Check other cells
				for other_cell in object_pool:
					if other_cell != c:
						if c.position.distance_to(other_cell.position) < (c.get_dimension() + other_cell.get_dimension()):
							overlapping = true
							c.position.x = randi_range(-dimension_terrain, dimension_terrain)
							c.position.y = randi_range(-dimension_terrain, dimension_terrain)
							break

func get_bassin() -> Array:
	return object_pool