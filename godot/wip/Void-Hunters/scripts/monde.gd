extends Node2D

var meteorite_pool : MeteoritePool = MeteoritePool.new()
var marqueur_manager := MarqueurManager.new()

@onready var spawner := $Spawner
@onready var joueur := $Joueur

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	meteorite_pool.player = joueur
	add_child(meteorite_pool)

	marqueur_manager.player = joueur
	add_child(marqueur_manager)

	spawner.connect("new_spawn_ready", Callable(self, "_on_new_spawn_ready"))
	spawner.autospawn = true



func _on_new_spawn_ready(position: Vector2) -> void:
	spawn_meteorite(position)


func spawn_meteorite(position: Vector2) -> void:
	var meteorite = meteorite_pool.get_instance()
	if meteorite != null:
		print("New spawn at: ", position)
		meteorite.position = position

		if not meteorite.touche.is_connected(Callable(self, "_on_meteorite_touche")):
			meteorite.connect("touche", Callable(self, "_on_meteorite_touche"))



		marqueur_manager.add_meteorite(meteorite)

func _process(delta: float) -> void:
	spawner.spawn_offset = joueur.position

func _on_meteorite_touche(meteorite: Meteorite, other: Node2D) -> void:
	if (other == joueur):
		joueur.appliquer_dommage(10)

		print("Meteorite visible : " + meteorite.texture_name)