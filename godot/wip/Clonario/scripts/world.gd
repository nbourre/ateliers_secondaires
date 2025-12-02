class_name World
extends Node

@onready var food_spawner : FoodSpawner = $FoodSpawner
@onready var player : Cell = $Player
@onready var cell_spawner : CellSpawner = $CellSpawner

var merged_objects := []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	food_spawner.set_no_spawn_area(player.global_position, player.get_no_spawn_radius())
	food_spawner.spawn_food()

	cell_spawner.spawn()

	# Get the pool of cells and food for further use
	var cells = cell_spawner.get_pool()
	var foods = food_spawner.get_pool()

	merged_objects = cells + foods

	# Provide each cell with the list of all eatable objects
	for c in cells:
		c.set_all_eatable_objects(merged_objects)
