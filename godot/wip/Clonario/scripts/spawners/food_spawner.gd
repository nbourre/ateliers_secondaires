class_name FoodSpawner
extends Node2D

@export var food : PackedScene
@export var nb_food : int = 100

var no_spawn_areas : Array[Dictionary] = []  # Array of {position: Vector2, radius: float}

var object_pool := []

func _ready() -> void:
	pass # Called when the node enters the scene tree for the first time.

func set_no_spawn_areas(areas: Array[Dictionary]) -> void:
	no_spawn_areas = areas

func is_position_valid(pos: Vector2) -> bool:
	for area in no_spawn_areas:
		if pos.distance_to(area.position) < area.radius:
			return false
	return true

func spawn_food():
	# This function can be expanded to respawn food while respecting the no-spawn area
	for i in nb_food:
		var f = food.instantiate() as Food
		f.name = "Food_%d" % i
		f.connect("eaten", Callable(self, "_on_food_eaten"))

		randomize()

		f.position.x = randi_range(-2000, 2000)
		f.position.y = randi_range(-2000, 2000)

		while not is_position_valid(f.position):
			f.position.x = randi_range(-2000, 2000)
			f.position.y = randi_range(-2000, 2000)

		add_child(f)
		object_pool.append(f)

func get_pool() -> Array:
	return object_pool

func _on_food_eaten(food_item : Food) -> void:
	food_item.position.x = randi_range(-2000, 2000)
	food_item.position.y = randi_range(-2000, 2000)
	while not is_position_valid(food_item.position):
		food_item.position.x = randi_range(-2000, 2000)
		food_item.position.y = randi_range(-2000, 2000)

		

func disable_food(food_item : Food) -> void:
	food_item.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	food_item.hide()

func enable_food(food_item : Food) -> void:
	food_item.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	food_item.show()