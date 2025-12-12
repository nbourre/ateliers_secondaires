class_name Monde
extends Node

@onready var generateur_bouffe : GenerateurBouffe = $GenerateurBouffe
@onready var player : Cellule = $Joueur
@onready var generateur_cellule : GenerateurCellule = $GenerateurCellule

var objets_fusionnes := []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set no-spawn area around player for cell spawner
	var cellule_rayons_sans_apparition : Array[Dictionary] = [{
		"position": player.global_position,
		"radius": player.get_rayon_sans_apparition()
	}]
	generateur_cellule.set_no_spawn_areas(cellule_rayons_sans_apparition)
	
	# Spawn cells first
	generateur_cellule.spawn()
	
	# Build no-spawn areas from player and spawned cells
	var zones_sans_apparition : Array[Dictionary] = []
	zones_sans_apparition.append({
		"position": player.global_position,
		"radius": player.get_rayon_sans_apparition()
	})
	
	# Add all spawned cells to no-spawn areas
	var cells = generateur_cellule.get_bassin()
	for cell in cells:
		zones_sans_apparition.append({
			"position": cell.global_position,
			"radius": cell.get_rayon_sans_apparition()
		})
	
	generateur_bouffe.set_zones_sans_apparition(zones_sans_apparition)
	generateur_bouffe.generer_bouffe()

	# Get the pool of food for further use
	var foods = generateur_bouffe.get_bassin()

	objets_fusionnes = cells + foods
	objets_fusionnes.append(player)

	# Provide each cell with the list of all eatable objects
	for c in cells:
		c.set_tous_objets_mangeables(objets_fusionnes)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.is_action_pressed("ui_cancel"):
			get_tree().quit()
