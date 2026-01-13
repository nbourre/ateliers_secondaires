class_name Monde
extends Node

@onready var generateur_bouffe : GenerateurBouffe
@onready var player : Cellule
@onready var generateur_cellule : GenerateurCellule

var objets_fusionnes := []


func _ready() -> void:
	player = get_node_or_null("Joueur") as Cellule
	generateur_bouffe = get_node_or_null("GenerateurBouffe")
	generateur_cellule = get_node_or_null("GenerateurCellule")

	# Zone interdite autour du joueur pour ne pas faire apparaître d'autres cellules.
	var cellule_rayons_sans_apparition : Array[Dictionary] = []
	if player != null:
		cellule_rayons_sans_apparition = [{
			"position": player.global_position,
			"radius": player.get_rayon_sans_apparition()
		}]

	var cells : Array = []
	if generateur_cellule != null:
		generateur_cellule.set_zones_sans_apparition(cellule_rayons_sans_apparition)
		generateur_cellule.generer()
		cells = generateur_cellule.get_bassin()
	else:
		push_warning("Aucun generateur_cellule dans la scène.")
	

	
	# Construire les zones interdites à partir du joueur et des cellules générées.
	var zones_sans_apparition : Array[Dictionary] = []
	if player != null:
		zones_sans_apparition.append({
			"position": player.global_position,
			"radius": player.get_rayon_sans_apparition()
		})
	
	# Ajouter chaque cellule générée à la liste des zones interdites.
	for cell in cells:
		zones_sans_apparition.append({
			"position": cell.global_position,
			"radius": cell.get_rayon_sans_apparition()
		})
	
	var foods : Array = []
	if generateur_bouffe != null:
		generateur_bouffe.set_zones_sans_apparition(zones_sans_apparition)
		generateur_bouffe.generer_bouffe()
		foods = generateur_bouffe.get_bassin()
	else:
		push_warning("Aucun generateur_bouffe dans la scène.")

	# Les objets mangeables sans générateur.
	foods += trouver_bouffe_sans_generateur()
	cells += trouver_cellule_sans_generateur()

	objets_fusionnes = cells + foods
	if player != null:
		objets_fusionnes.append(player)

	# Donne à chaque cellule la liste des objets mangeables.
	for c in cells:
		c.set_tous_objets_mangeables(objets_fusionnes)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.is_action_pressed("ui_cancel"):
			get_tree().quit()

func trouver_bouffe_sans_generateur() -> Array:
	var bouffes_sans_generateur : Array = []

	# Trouver les noeuds de type Bouffe dans le monde.
	for enfant in get_children():
		if enfant is Bouffe:
			enfant.connect("eaten", Callable(self, "bouffe_mangee_sans_generateur"))
			bouffes_sans_generateur.append(enfant)
	return bouffes_sans_generateur

func bouffe_mangee_sans_generateur(bouffe: Bouffe) -> void:
	# Réapparaitre la bouffe à une position aléatoire.
	bouffe.queue_free()

func trouver_cellule_sans_generateur() -> Array:
	var cellules_sans_generateur : Array = []

	# Trouver les noeuds de type Cellule dans le monde.
	for enfant in get_children():
		if enfant is Cellule:

			if enfant.name != "Joueur":
				print("Cellule sans générateur trouvée : " + enfant.name)
				cellules_sans_generateur.append(enfant)
	return cellules_sans_generateur