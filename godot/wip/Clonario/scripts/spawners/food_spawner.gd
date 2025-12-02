class_name FoodSpawner
extends Node2D

@export var food : PackedScene
@export var nb_food : int = 100
@export var no_spawn_radius : float = 0.0

var no_spawn_point : Vector2

var object_pool := []

func _ready() -> void:
	pass # Called when the node enters the scene tree for the first time.

func set_no_spawn_area(center : Vector2, radius: float) -> void:
	no_spawn_point = center
	no_spawn_radius = radius

func spawn_food():
	# This function can be expanded to respawn food while respecting the no-spawn area
	for i in nb_food:
		var f = food.instantiate() as Food
		f.name = "Food_%d" % i
		f.connect("eaten", Callable(self, "_on_food_eaten"))

		randomize()

		f.position.x = randi_range(-2000, 2000)
		f.position.y = randi_range(-2000, 2000)

		while f.position.distance_to(no_spawn_point) < no_spawn_radius:
			f.position.x = randi_range(-2000, 2000)
			f.position.y = randi_range(-2000, 2000)

		add_child(f)
		object_pool.append(f)

func get_pool() -> Array:
	return object_pool

func _on_food_eaten(food_item : Food) -> void:
	food_item.position.x = randi_range(-2000, 2000)
	food_item.position.y = randi_range(-2000, 2000)
	while food_item.position.distance_to(no_spawn_point) < no_spawn_radius:
			food_item.position.x = randi_range(-2000, 2000)
			food_item.position.y = randi_range(-2000, 2000)

		

func disable_food(food_item : Food) -> void:
	food_item.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	food_item.hide()

func enable_food(food_item : Food) -> void:
	food_item.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	food_item.show()