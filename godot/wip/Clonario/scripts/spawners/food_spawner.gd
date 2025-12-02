class_name FoodSpawner
extends Node2D

@export var food : PackedScene
@export var nb_food : int = 100
@export var no_spawn_radius : float = 0.0

var no_spawn_point : Vector2

var object_pool := []

func set_no_spawn_area(center : Vector2, radius: float) -> void:
	no_spawn_point = center
	no_spawn_radius = radius

func spawn_food():
	# This function can be expanded to respawn food while respecting the no-spawn area
	for i in nb_food:
		var f = food.instantiate() as Food
		f.name = "Food_%d" % i
		add_child(f)
		object_pool.append(f)
		randomize()

		f.position.x = randi_range(-2000, 2000)
		f.position.y = randi_range(-2000, 2000)

		while f.position.distance_to(no_spawn_point) < no_spawn_radius:
			f.position.x = randi_range(-2000, 2000)
			f.position.y = randi_range(-2000, 2000)

func get_pool() -> Array:
	return object_pool