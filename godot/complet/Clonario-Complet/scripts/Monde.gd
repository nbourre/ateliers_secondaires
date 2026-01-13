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
