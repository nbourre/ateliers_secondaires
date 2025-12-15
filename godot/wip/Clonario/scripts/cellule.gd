class_name Cellule
extends CharacterBody2D

@export var controleur : Controleur
@export var rayon_sans_apparition := 250.0

# Système d’énergie : combien de temps la cellule peut aller vite.
@export_group("Energy")	
@export var energie_chasse_max := 5.0  # Secondes de chasse avant d’être à plat
@export var energie_fuite_max := 3.0   # Secondes de fuite avant d’être à plat
@export var vitesse_recharge_chasse := 1.0  # Vitesse de recharge en chasse
@export var vitesse_recharge_fuite := 2.0   # La fuite se recharge 2x plus vite

var energie_chasse := energie_chasse_max  # Énergie de chasse actuelle
var energie_fuite := energie_fuite_max     # Énergie de fuite actuelle

var barre_energie_chasse : TextureProgressBar
var barre_energie_fuite : TextureProgressBar

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

	barre_energie_fuite = get_node_or_null("BarreEnergieFuite")
	barre_energie_chasse = get_node_or_null("BarreEnergieChasse")

	mettre_a_jour_barres_energie()

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
	return max(0.1, speed_multiplier) as float

func get_rayon_sans_apparition() -> float:
	return rayon_sans_apparition

func _physics_process(delta: float) -> void:
	suivi_intersection()

	if controleur != null:
		# Demande au contrôleur quoi faire : "chasse", "fuite", "broute" ou "inactif".
		var comportement = controleur.get_comportement()
		var peut_chasser = energie_chasse > 0
		var peut_fuire = energie_fuite > 0
		
		var vitesse_cible = controleur.get_mouvement_avec_energie(peut_chasser, peut_fuire)
		
		# Gestion de l’énergie selon l’action en cours.
		if comportement == "chasse":
			if peut_chasser:
				# On dépense l’énergie de chasse (pas de recharge pendant la chasse).
				energie_chasse = max(0, energie_chasse - delta)
			# Pas de recharge tant qu’on chasse.
			
		elif comportement == "fuite":
			if peut_fuire:
				# On dépense l’énergie de fuite (pas de recharge pendant la fuite).
				energie_fuite = max(0, energie_fuite - delta)
				# Pas de recharge tant qu’on fuit.
			
		elif comportement == "broute":
			# Brouter = manger = ça recharge les deux jauges.
			energie_chasse = min(energie_chasse_max, energie_chasse + vitesse_recharge_chasse * delta)
			energie_fuite = min(energie_fuite_max, energie_fuite + vitesse_recharge_fuite * delta)
			
		else:  # inactif ou déplacement normal
			# Repos : recharge des deux jauges.
			energie_chasse = min(energie_chasse_max, energie_chasse + vitesse_recharge_chasse * delta)
			energie_fuite = min(energie_fuite_max, energie_fuite + vitesse_recharge_fuite * delta)
		
		mettre_a_jour_barres_energie()

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
		# Déboggage : visualiser les contacts entre cellules.
		if obj is Area2D and obj.get_parent() is Cellule:

			var autre_cellule : Cellule = obj.get_parent() as Cellule

			if autre_cellule.get_dimension() == taille:
				# Only care about different sized cells
				continue

			var distance := global_position.distance_to(autre_cellule.global_position)

			# Correction : utiliser les rayons réels pour plus de précision.
			if (distance < get_dimension()/3):
				#print("Distance : " + str(distance) + "\t Taille : " + str(autre_cellule.get_dimension()))
			
				if autre_cellule.get_dimension() < taille:
					#print("Distance : " + str(distance) + "\t Taille : " + str(autre_cellule.get_dimension()))
					autre_cellule.mourir()
					grandir(autre_cellule.get_life() * 0.25)
					continue
				else:
					mourir()
					continue

func mourir() -> void:
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

func mettre_a_jour_barres_energie() -> void:
	if barre_energie_chasse != null:
		barre_energie_chasse.update_value(energie_chasse, energie_chasse_max)
	
	if barre_energie_fuite != null:
		barre_energie_fuite.update_value(energie_fuite, energie_fuite_max)
		if energie_fuite != energie_fuite_max:
			print ("Énergie fuite : " + str(energie_fuite) + " / " + str(energie_fuite_max))