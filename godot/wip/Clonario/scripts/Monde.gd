class_name Monde
extends Node

@onready var generateur_bouffe : GenerateurBouffe = $GenerateurBouffe
@onready var player : Cellule = $Joueur
@onready var generateur_cellule : GenerateurCellule = $GenerateurCellule

var objets_fusionnes := []


func _ready() -> void:
	# Zone interdite autour du joueur pour ne pas faire apparaître d’autres cellules.
	var cellule_rayons_sans_apparition : Array[Dictionary] = [{
		"position": player.global_position,
		"radius": player.get_rayon_sans_apparition()
	}]
	generateur_cellule.set_zones_sans_apparition(cellule_rayons_sans_apparition)
	
	# Générer d’abord les cellules.
	generateur_cellule.generer()
	
	# Construire les zones interdites à partir du joueur et des cellules générées.
	var zones_sans_apparition : Array[Dictionary] = []
	zones_sans_apparition.append({
		"position": player.global_position,
		"radius": player.get_rayon_sans_apparition()
	})
	
	# Ajouter chaque cellule générée à la liste des zones interdites.
	var cells = generateur_cellule.get_bassin()
	for cell in cells:
		zones_sans_apparition.append({
			"position": cell.global_position,
			"radius": cell.get_rayon_sans_apparition()
		})
	
	generateur_bouffe.set_zones_sans_apparition(zones_sans_apparition)
	generateur_bouffe.generer_bouffe()

	# Récupère la liste de toute la bouffe générée.
	var foods = generateur_bouffe.get_bassin()

	objets_fusionnes = cells + foods
	objets_fusionnes.append(player)

	# Donne à chaque cellule la liste des objets mangeables.
	for c in cells:
		c.set_tous_objets_mangeables(objets_fusionnes)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.is_action_pressed("ui_cancel"):
			get_tree().quit()
