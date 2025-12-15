class_name GenerateurCellule
extends Node

@export var scene_cellule : PackedScene
@export var nb_cellules : int = 25
@export var controleur_cellule : Script

var bassin_objets := []
var zone_sans_reapparition : Array[Dictionary] = []  # Tableau de {position: Vector2, radius: float}

var dimension_terrain : float = 1500.0

func set_zones_sans_apparition(areas: Array[Dictionary]) -> void:
	zone_sans_reapparition = areas

func est_valide_position(pos: Vector2) -> bool:
	for zone in zone_sans_reapparition:
		if pos.distance_to(zone.position) < zone.radius:
			return false
	return true

func generer():
	for i in nb_cellules:
		var c = scene_cellule.instantiate() as Cellule
		bassin_objets.append(c)
		c.name = "Cell_%d" % i
		c.set_nom(c.name)
		add_child(c)
		c.set_controleur(controleur_cellule.new() as Controleur)
		randomize()
		c.get_sprite().modulate = Color(randf(), randf(), randf())

		c.position.x = randi_range(-dimension_terrain, dimension_terrain)
		c.position.y = randi_range(-dimension_terrain, dimension_terrain)

		# Vérifie pour éviter les chevauchements et respecter les zones interdites.
		if (i > 0):
			var chevauchement := true
			while chevauchement:
				chevauchement = false
				
				# Vérifie les zones sans apparition.
				if not est_valide_position(c.position):
					chevauchement = true
					c.position.x = randi_range(-dimension_terrain, dimension_terrain)
					c.position.y = randi_range(-dimension_terrain, dimension_terrain)
					continue
				
				# Vérifie les chevauchements avec les autres cellules.
				for autre_cellule in bassin_objets:
					if autre_cellule != c:
						if c.position.distance_to(autre_cellule.position) < (c.get_dimension() + autre_cellule.get_dimension()):
							chevauchement = true
							c.position.x = randi_range(-dimension_terrain, dimension_terrain)
							c.position.y = randi_range(-dimension_terrain, dimension_terrain)
							break

func get_bassin() -> Array:
	return bassin_objets