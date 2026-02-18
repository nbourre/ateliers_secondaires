extends Node2D

var meteorite_pool : MeteoritePool = MeteoritePool.new()
var marqueur_manager := MarqueurManager.new()

var score := 0

@onready var spawner := $Spawner
@onready var joueur := $Joueur

@onready var barre_vie := $CanvasLayer/Sante/Sante
@onready var score_label := $CanvasLayer/Pointage/Score

@onready var menu := $CanvasLayer/Menu

@onready var meteorite_impulsion_force_min := 50.0
@onready var meteorite_impulsion_force_max := 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	menu.demarrer_partie.connect(nouvelle_partie)

	meteorite_pool.player = joueur
	meteorite_pool.pool_size = 20
	add_child(meteorite_pool)

	marqueur_manager.player = joueur
	add_child(marqueur_manager)

	spawner.connect("new_spawn_ready", Callable(self, "_on_new_spawn_ready"))

	joueur.visible = false
	joueur.sante_changee.connect(Callable(self, "_on_joueur_sante_changee"))
	joueur.est_mort.connect(Callable(self, "_on_joueur_est_mort"))

	barre_vie.update_value(joueur.sante, joueur.max_sante)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	if Input.is_action_just_pressed("ui_accept"):
		meteorite_pool.toggle_sleeping()

	spawner.position = joueur.position
	
func nouvelle_partie():
	score = 0
	score_label.text = str(score)
	menu.afficher_msg("Prépare-toi!")
	joueur.visible = true
	spawner.autospawn = true
	joueur.tir_active = true

func fin_partie():
	spawner.autospawn = false
	joueur.tir_active = false
	menu.afficher_fin_partie()

func _on_new_spawn_ready(pos: Vector2) -> void:
	spawn_meteorite(pos)

func spawn_meteorite(pos: Vector2) -> void:
	var meteorite = meteorite_pool.get_instance()
	if meteorite != null:
		meteorite.position = pos

		if not meteorite.touche.is_connected(Callable(self, "_on_meteorite_touche")):
			meteorite.connect("touche", Callable(self, "_on_meteorite_touche"))

		if not meteorite.detruite.is_connected(Callable(self, "_on_meteorite_detruite")):
			meteorite.connect("detruite", Callable(self, "_on_meteorite_detruite"))

		goto_player(meteorite)
		marqueur_manager.add_meteorite(meteorite)



func _on_meteorite_touche(_meteorite: Meteorite, other: Node2D) -> void:
	if (other == joueur):
		joueur.appliquer_dommage(10)

func goto_player(m: Meteorite) -> void:
	if joueur == null:
		return
	
	var direction = (joueur.global_position - m.global_position).normalized()
	var random_impulsion := randf_range(meteorite_impulsion_force_min, meteorite_impulsion_force_max)

	if m.is_respawned:
		random_impulsion *= 10.0  # Patch : Give a stronger impulse for newly spawned meteorites
		m.start_position = m.position

	m.donner_impulsion(direction * random_impulsion)  # Adjust the impulse strength as needed

func _on_joueur_sante_changee() -> void:
	barre_vie.update_value(joueur.sante, joueur.max_sante)

func _on_joueur_est_mort() -> void:
	fin_partie()

func _on_meteorite_detruite(_meteorite: Meteorite) -> void:
	score += 10
	score_label.text = str(score)
