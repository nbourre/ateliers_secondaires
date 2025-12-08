class_name World
extends Node

@onready var food_spawner : FoodSpawner = $FoodSpawner
@onready var player : Cell = $Player
@onready var cell_spawner : CellSpawner = $CellSpawner

var merged_objects := []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set no-spawn area around player for cell spawner
	var cell_no_spawn_areas : Array[Dictionary] = [{
		"position": player.global_position,
		"radius": player.get_no_spawn_radius()
	}]
	cell_spawner.set_no_spawn_areas(cell_no_spawn_areas)
	
	# Spawn cells first
	cell_spawner.spawn()
	
	# Build no-spawn areas from player and spawned cells
	var no_spawn_areas : Array[Dictionary] = []
	no_spawn_areas.append({
		"position": player.global_position,
		"radius": player.get_no_spawn_radius()
	})
	
	# Add all spawned cells to no-spawn areas
	var cells = cell_spawner.get_pool()
	for cell in cells:
		no_spawn_areas.append({
			"position": cell.global_position,
			"radius": cell.get_no_spawn_radius()
		})
	
	food_spawner.set_no_spawn_areas(no_spawn_areas)
	food_spawner.spawn_food()

	# Get the pool of food for further use
	var foods = food_spawner.get_pool()

	merged_objects = cells + foods
	merged_objects.append(player)

	# Provide each cell with the list of all eatable objects
	for c in cells:
		c.set_all_eatable_objects(merged_objects)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()