extends Node2D

var meteorite_pool : MeteoritePool = MeteoritePool.new()
var marqueur_manager := MarqueurManager.new()

@onready var spawner := $Spawner
@onready var joueur := $Joueur

@onready var barre_vie := $CanvasLayer/HBoxContainer/Sante

@onready var meteorite_impulsion_force_min := 50.0
@onready var meteorite_impulsion_force_max := 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	meteorite_pool.player = joueur
	meteorite_pool.pool_size = 20
	add_child(meteorite_pool)

	marqueur_manager.player = joueur
	add_child(marqueur_manager)

	spawner.connect("new_spawn_ready", Callable(self, "_on_new_spawn_ready"))
	spawner.autospawn = true

	joueur.sante_changee.connect(Callable(self, "_on_joueur_sante_changee"))
	joueur.est_mort.connect(Callable(self, "_on_joueur_est_mort"))
	barre_vie.update_value(joueur.sante, joueur.max_sante)

	

func _on_new_spawn_ready(position: Vector2) -> void:
	spawn_meteorite(position)

func spawn_meteorite(position: Vector2) -> void:
	var meteorite = meteorite_pool.get_instance()
	if meteorite != null:
		#print("New spawn at: ", position)
		meteorite.position = position
		goto_player(meteorite)

		if not meteorite.touche.is_connected(Callable(self, "_on_meteorite_touche")):
			meteorite.connect("touche", Callable(self, "_on_meteorite_touche"))

		marqueur_manager.add_meteorite(meteorite)

func _process(_delta: float) -> void:
	spawner.position = joueur.position


func _on_meteorite_touche(meteorite: Meteorite, other: Node2D) -> void:
	if (other == joueur):
		joueur.appliquer_dommage(10)

		print("Meteorite visible : " + meteorite.texture_name)

func goto_player(m: Meteorite) -> void:
	if joueur == null:
		return
	
	var direction = (joueur.global_position - m.global_position).normalized()
	var random_impulsion := randf_range(meteorite_impulsion_force_min, meteorite_impulsion_force_max)
	m.donner_impulsion(direction * random_impulsion)  # Adjust the impulse strength as needed

func _on_joueur_sante_changee() -> void:
	barre_vie.update_value(joueur.sante, joueur.max_sante)

func _on_joueur_est_mort() -> void:
	spawner.autospawn = false
	pass
