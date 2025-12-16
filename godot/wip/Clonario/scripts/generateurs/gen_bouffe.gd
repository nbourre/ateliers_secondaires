class_name GenerateurBouffe
extends Node2D

@export var food : PackedScene
@export var nb_food : int = 250

var no_spawn_areas : Array[Dictionary] = []  # Tableau de {position: Vector2, radius: float}

var object_pool := []

var sandbox_size : float = 2000.0

func _ready() -> void:
	pass # Point d’entrée du générateur.

func set_zones_sans_apparition(areas: Array[Dictionary]) -> void:
	no_spawn_areas = areas

func is_position_valid(pos: Vector2) -> bool:
	for area in no_spawn_areas:
		if pos.distance_to(area.position) < area.radius:
			return false
	return true

func generer_bouffe():
	# Peut être étendue pour réapparaître la bouffe en respectant les zones interdites.
	for i in nb_food:
		var f = food.instantiate() as Bouffe
		f.name = "Bouffe_%d" % i
		f.connect("eaten", Callable(self, "_on_food_eaten"))

		randomize()

		f.position.x = randi_range(-sandbox_size, sandbox_size)
		f.position.y = randi_range(-sandbox_size, sandbox_size)

		while not is_position_valid(f.position):
			f.position.x = randi_range(-sandbox_size, sandbox_size)
			f.position.y = randi_range(-sandbox_size, sandbox_size)

		add_child(f)
		object_pool.append(f)

func get_bassin() -> Array:
	return object_pool

func _on_food_eaten(food_item : Bouffe) -> void:
	food_item.position.x = randi_range(-sandbox_size, sandbox_size)
	food_item.position.y = randi_range(-sandbox_size, sandbox_size)
	while not is_position_valid(food_item.position):
		food_item.position.x = randi_range(-sandbox_size, sandbox_size)
		food_item.position.y = randi_range(-sandbox_size, sandbox_size)

func disable_food(food_item : Bouffe) -> void:
	food_item.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	food_item.hide()

func enable_food(food_item : Bouffe) -> void:
	food_item.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	food_item.show()
