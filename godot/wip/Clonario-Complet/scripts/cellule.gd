class_name Cellule
extends CharacterBody2D

@export var controleur : Controleur
@export var rayon_sans_apparition := 250.0


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

	barre_energie_fuite = get_node_or_null("EnergieFuite")
	barre_energie_chasse = get_node_or_null("EnergieChasse")

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
		# Obtient la vitesse cible du contrôleur
		# Pense au contrôleur comme le cerveau de la cellule.
		var vitesse_cible = controleur.get_mouvement_avec_energie()

		# Lisse le mouvement pour éviter les changements brusques.
		velocity = velocity.lerp(vitesse_cible, 0.1)

		# Met à jour les barres avec les valeurs du contrôleur
		if barre_energie_chasse != null:
			barre_energie_chasse.update_value(controleur.get_energie_chasse(), controleur.get_energie_chasse_max())
		if barre_energie_fuite != null:
			barre_energie_fuite.update_value(controleur.get_energie_fuite(), controleur.get_energie_fuite_max())

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
