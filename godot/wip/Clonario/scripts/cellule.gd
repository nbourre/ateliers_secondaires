class_name Cellule
extends CharacterBody2D

@export var controleur : Controleur
@export var rayon_sans_apparition := 250.0

# Energy System - How long can the cell run fast?
@export_group("Energy")
@export var energie_chasse_max := 5.0  # Seconds of chasing before tired
@export var energie_fuite_max := 3.0   # Seconds of fleeing before tired
@export var vitesse_recharge_chasse := 1.0  # How fast chase energy comes back
@export var vitesse_recharge_fuite := 2.0   # Flee recharges 2x faster!

var energie_chasse := energie_chasse_max  # Current chase energy
var energie_fuite := energie_fuite_max     # Current flee energy

const VITESSE_BASE := 1000.0

var vie := 10.0;
var echelle_initiale : float
var rayon : float
var ratio_rayon : float

var sprite : Sprite2D
var taille : float
var est_chevauchee : bool = false

var zone_activation : Area2D
var direction := Vector2.ZERO

var message_pas_controleur := true

var objets_zone_activation := []

func _ready() -> void:
	sprite = $Circle
	echelle_initiale = scale.x
	rayon = sqrt(vie / PI)
	ratio_rayon = echelle_initiale / rayon

	zone_activation = $Activation
	set_vie(vie)


func set_vie(nouvelle_vie : float) -> void:
	vie = nouvelle_vie
	
	rayon = sqrt(vie / PI)
	scale.x = rayon * ratio_rayon
	scale.y = scale.x
	
	set_taille(sprite.texture.get_size().x * scale.x)

func grandir(value : float) -> void:
	set_vie(vie + value)

func get_multiplicateur_vitesse() -> float:
	var speed_multiplier := VITESSE_BASE / (vie + VITESSE_BASE)
	return max(0.1, speed_multiplier)

func get_rayon_sans_apparition() -> float:
	return rayon_sans_apparition

func _physics_process(delta: float) -> void:
	suivi_intersection()

	if controleur != null:
		# Ask the controleur what it wants to do
		var comportement = controleur.get_comportement()  # "chasse", "fuite", or "inactif"
		var peut_chasser = energie_chasse > 0
		var peut_fuire = energie_fuite > 0
		
		var vitesse_cible = controleur.get_mouvement_avec_energie(peut_chasser, peut_fuire)
		
		# Energy management based on what the cell is doing
		if comportement == "chasse":
			if peut_chasser:
				# Using chase energy! No recharge while chasing
				energie_chasse = max(0, energie_chasse - delta)
			# No recharge for either energy while actively chasing
			
		elif comportement == "fuite":
			if peut_fuire:
				# Using flee energy! No recharge while fleeing
				energie_fuite = max(0, energie_fuite - delta)
			# No recharge for either energy while actively fleeing
			
		elif comportement == "broute":
			# Grazing = eating food = recovering energy!
			energie_chasse = min(energie_chasse_max, energie_chasse + vitesse_recharge_chasse * delta)
			energie_fuite = min(energie_fuite_max, energie_fuite + vitesse_recharge_fuite * delta)
			
		else:  # inactif or moving normalement
			# Resting - recharge both energies!
			energie_chasse = min(energie_chasse_max, energie_chasse + vitesse_recharge_chasse * delta)
			energie_fuite = min(energie_fuite_max, energie_fuite + vitesse_recharge_fuite * delta)
		
		velocity = velocity.lerp(vitesse_cible, 0.1)
		
	else:
		if message_pas_controleur:
			print("Aucun contrôleur assigné à la cellule: " + str(self.name))
			message_pas_controleur = false
	
	move_and_slide()

func _on_activation_area_entered(_area: Area2D) -> void:
	est_chevauchee = zone_activation.get_overlapping_areas().size() > 0

func _on_activation_area_exited(_area: Area2D) -> void:
	est_chevauchee = zone_activation.get_overlapping_areas().size() > 0

func suivi_intersection() -> void:
	est_chevauchee = zone_activation.get_overlapping_areas().size() > 0
	if not est_chevauchee :
		sprite.modulate = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 1.0)
		return

	sprite.modulate = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 0.5)

	for obj in zone_activation.get_overlapping_areas():
		# For debugging purposes
		if obj is Area2D and obj.get_parent() is Cellule:

			var autre_cellule : Cellule = obj.get_parent() as Cellule

			if autre_cellule.get_dimension() == taille:
				# Only care about different sized cells
				continue

			var distance := global_position.distance_to(autre_cellule.global_position)

			# Fix : La distance n'est pas assez précise, nous devons vérifier les rayons réels
			if (distance < get_dimension()/3):
				print("Distance: " + str(distance) + "\t Size : " + str(autre_cellule.get_dimension()))
			
				if autre_cellule.get_dimension() < taille:
					print("Distance: " + str(distance) + "\t Size : " + str(autre_cellule.get_dimension()))
					autre_cellule.die()
					grandir(autre_cellule.get_life() * 0.25)
					continue
				else:
					die()
					continue

func die() -> void:
	if controleur != null:
		controleur.mourir()	

func set_controleur(the_controller : Controleur) -> void:
	controleur = the_controller
	add_child(controleur)
	message_pas_controleur = false

func get_sprite() -> Sprite2D:
	return sprite

func get_life() -> float:
	return vie

func get_radius() -> float:
	return rayon

func get_dimension() -> float:
	return taille

func set_taille(new_size : float) -> void:
	taille = new_size

func set_nom(new_name : String) -> void:
	name = new_name
	$NameLabel.text = new_name

func set_tous_objets_mangeables(objets : Array) -> void:
	var tous_objets_mangeables := []
	tous_objets_mangeables = objets
	controleur.set_tous_objets_mangeables(tous_objets_mangeables)