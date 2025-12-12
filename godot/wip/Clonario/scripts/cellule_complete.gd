#class_name Cellule
extends CharacterBody2D

@export var controleur : Controleur
@export var rayon_sans_apparition := 250.0

# Système d'énergie - Combien de temps la cellule peut-elle courir vite?
@export_group("Énergie")
@export var energie_chasse_max := 5.0  # Secondes de chasse avant fatigue
@export var energie_fuite_max := 3.0   # Secondes de fuite avant fatigue
@export var vitesse_recharge_chasse := 1.0  # Vitesse de récupération de l'énergie de chasse
@export var vitesse_recharge_fuite := 2.0   # Fuite se recharge 2x plus rapide!

var energie_chasse := energie_chasse_max  # Énergie de chasse actuelle
var energie_fuite := energie_fuite_max     # Énergie de fuite actuelle

const FACTEUR_BASE_VITESSE := 1000.0

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

func grandir(valeur : float) -> void:
	set_vie(vie + valeur)

	print("Vie : " + str(vie))

func get_multiplicateur_vitesse() -> float:
	var multiplicateur_vitesse := FACTEUR_BASE_VITESSE / (vie + FACTEUR_BASE_VITESSE)
	return max(0.1, multiplicateur_vitesse)

func get_rayon_sans_apparition() -> float:
	return rayon_sans_apparition

func _physics_process(delta: float) -> void:
	surveiller_chevauchement()

	if controleur != null:
		# Demander au contrôleur ce qu'il veut faire
		var comportement = controleur.get_comportement()  # "chasse", "fuite", ou "repos"
		var peut_chasser = energie_chasse > 0
		var peut_fuir = energie_fuite > 0
		
		var vitesse_cible = controleur.get_mouvement_avec_energie(peut_chasser, peut_fuir)
		
		# Gestion de l'énergie en fonction de ce que fait la cellule
		if comportement == "chasse":
			if peut_chasser:
				# Utilisation de l'énergie de chasse! Pas de recharge pendant la chasse
				energie_chasse = max(0, energie_chasse - delta)
			# Pas de recharge d'énergie pendant la chasse active
			
		elif comportement == "fuite":
			if peut_fuir:
				# Utilisation de l'énergie de fuite! Pas de recharge pendant la fuite
				energie_fuite = max(0, energie_fuite - delta)
			# Pas de recharge d'énergie pendant la fuite active
			
		elif comportement == "paissance":
			# Paissance = manger de la nourriture = récupérer de l'énergie!
			energie_chasse = min(energie_chasse_max, energie_chasse + vitesse_recharge_chasse * delta)
			energie_fuite = min(energie_fuite_max, energie_fuite + vitesse_recharge_fuite * delta)
			
		else:  # repos ou mouvement normal
			# Repos - recharge les deux énergies!
			energie_chasse = min(energie_chasse_max, energie_chasse + vitesse_recharge_chasse * delta)
			energie_fuite = min(energie_fuite_max, energie_fuite + vitesse_recharge_fuite * delta)
		
		velocity = velocity.lerp(vitesse_cible, 0.1)
		
	else:
		if message_pas_controleur:
			print("Aucun contrôleur assigné à Cellule: " + str(self.name))
			message_pas_controleur = false
	
	move_and_slide()

func _on_zone_activation_entree(_area: Area2D) -> void:
	est_chevauchee = zone_activation.get_overlapping_areas().size() > 0

func _on_zone_activation_sortie(_area: Area2D) -> void:
	est_chevauchee = zone_activation.get_overlapping_areas().size() > 0

func surveiller_chevauchement() -> void:
	est_chevauchee = zone_activation.get_overlapping_areas().size() > 0
	if not est_chevauchee :
		sprite.modulate = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 1.0)
		return

	sprite.modulate = Color(sprite.modulate.r, sprite.modulate.g, sprite.modulate.b, 0.5)

	for obj in zone_activation.get_overlapping_areas():
		# À des fins de débogage
		if obj is Area2D and obj.get_parent() is Cellule:

			var autre_cellule : Cellule = obj.get_parent() as Cellule

			if autre_cellule.get_taille() == taille:
				# Ignorer les cellules de même taille
				continue

			var distance := global_position.distance_to(autre_cellule.global_position)

			# Correction : La distance n'est pas suffisante, nous devons vérifier les rayons réels
			if (distance < get_taille()/3):
				print("Distance: " + str(distance) + "\t Taille : " + str(autre_cellule.get_taille()))
			
				if autre_cellule.get_taille() < taille:
					print("Distance: " + str(distance) + "\t Taille : " + str(autre_cellule.get_taille()))
					autre_cellule.mourir()
					grandir(autre_cellule.get_vie() * 0.25)
					continue
				else:
					mourir()
					continue

func mourir() -> void:
	if controleur != null:
		controleur.mourir()	

func set_controleur(le_controleur : Controleur) -> void:
	controleur = le_controleur
	add_child(controleur)
	message_pas_controleur = false

func get_sprite() -> Sprite2D:
	return sprite

func get_vie() -> float:
	return vie

func get_rayon() -> float:
	return rayon

func get_taille() -> float:
	return taille

func set_taille(nouvelle_taille : float) -> void:
	taille = nouvelle_taille

func set_etiquette(nouveau_nom : String) -> void:
	name = nouveau_nom
	$NameLabel.text = nouveau_nom

func set_tous_objets_mangeables(objets : Array) -> void:
	var tous_objets_mangeables := []
	tous_objets_mangeables = objets
	controleur.set_objets_mangeables(tous_objets_mangeables)
