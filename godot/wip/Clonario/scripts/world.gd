class_name World
extends Node

@onready var food_spawner : FoodSpawner = $FoodSpawner
@onready var player : Cell = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	food_spawner.set_no_spawn_area(player.global_position, player.get_no_spawn_radius())
	food_spawner.spawn_food()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
