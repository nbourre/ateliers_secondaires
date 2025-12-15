class_name ControleurJoueur
extends Controleur

var direction := Vector2.ZERO
var dir_stop := 150.0

# Vitesses pour différents modes
var vitesse_normale := 6000.0
var vitesse_chasse := 8000.0
var vitesse_fuite := 10000.0

# État actuel du joueur
var mode_chasse := false
var mode_fuite := false

# Système d'énergie du contrôleur joueur
@export var energie_chasse_max := 5.0
@export var energie_fuite_max := 3.0
@export var vitesse_recharge_chasse := 1.0
@export var vitesse_recharge_fuite := 2.0

var energie_chasse := energie_chasse_max
var energie_fuite := energie_fuite_max

var vecteur_deplacement := Vector2.ZERO

var ma_cellule : Cellule
var camera : Camera2D

# Paramètres du zoom de la caméra
@export var zoom_min := 0.3  # Zoom minimum (très dézoomé)
@export var zoom_max := 1.0  # Zoom maximum (zoomé)
@export var taille_base := 50.0  # Taille de cellule pour zoom max
@export var taille_max_zoom := 500.0  # Taille où on atteint le zoom min
@export var vitesse_transition_zoom := 2.0  # Vitesse de transition du zoom

func _ready() -> void:
	ma_cellule = get_parent() as Cellule
	# Trouver la caméra dans la cellule
	if ma_cellule != null:
		camera = ma_cellule.get_node_or_null("Camera2D")


func _process(delta: float) -> void:
	# Vérifier les touches pour chasse et fuite
	mode_chasse = Input.is_action_pressed("chasse")
	mode_fuite = Input.is_action_pressed("fuite")
	
	# Ajuster le zoom de la caméra
	ajuster_zoom_camera(delta)
	
	var dir := get_direction_souris()
	
	# Déterminer la vitesse selon le mode
	var vitesse_actuelle := vitesse_normale
	if mode_fuite:
		vitesse_actuelle = vitesse_fuite
	elif mode_chasse:
		vitesse_actuelle = vitesse_chasse

	if dir.length() < dir_stop:
		# Arrêt progressif
		direction = direction.lerp(Vector2.ZERO, 0.1)
		vecteur_deplacement = direction
	else:
		direction = direction.lerp(dir.normalized() * vitesse_actuelle * delta, 0.1)
		vecteur_deplacement = direction

func get_mouvement() -> Vector2:
	return vecteur_deplacement

func get_mouvement_avec_energie() -> Vector2:
	var multiplicateur_dim := ma_cellule.get_multiplicateur_vitesse()
	var multiplicateur_energie := 1.0
	
	# Gestion de l'énergie selon l'action
	if mode_chasse:
		if energie_chasse > 0.0:
			energie_chasse = max(0.0, energie_chasse - get_process_delta_time())
		else:
			multiplicateur_energie = 0.5
	elif mode_fuite:
		if energie_fuite > 0.0:
			energie_fuite = max(0.0, energie_fuite - get_process_delta_time())
		else:
			multiplicateur_energie = 0.3
	else:
		# Repos : recharge
		energie_chasse = min(energie_chasse_max, energie_chasse + vitesse_recharge_chasse * get_process_delta_time())
		energie_fuite = min(energie_fuite_max, energie_fuite + vitesse_recharge_fuite * get_process_delta_time())
	
	var multiplicateur_total := multiplicateur_dim * multiplicateur_energie
	return vecteur_deplacement * multiplicateur_total

func mourir() -> void:
	get_tree().reload_current_scene()

# Vecteur normalisé du centre de l’écran vers la souris.
func get_direction_souris() -> Vector2:
	#var mouse_global := DisplayServer.mouse_get_position() as Vector2
	var mouse_vp := get_viewport().get_mouse_position()
	var screen_center := get_viewport().get_visible_rect().size / 2
	var dir := mouse_vp - screen_center
	
	return dir


func ajuster_zoom_camera(delta: float) -> void:
	if ma_cellule == null or camera == null:
		return
	
	# Obtenir la taille actuelle de la cellule
	var taille_actuelle = ma_cellule.get_dimension()
	
	# Calculer le facteur de zoom basé sur la taille
	# Interpolation linéaire entre taille_base et taille_max_zoom
	var facteur = clamp((taille_actuelle - taille_base) / (taille_max_zoom - taille_base), 0.0, 1.0)
	
	# Interpoler entre zoom_max et zoom_min
	var zoom_cible = lerp(zoom_max, zoom_min, facteur)
	
	# Transition douce vers le zoom cible
	var zoom_actuel = camera.zoom.x
	var nouveau_zoom = lerp(zoom_actuel, zoom_cible, vitesse_transition_zoom * delta)
	
	camera.zoom = Vector2(nouveau_zoom, nouveau_zoom)

func get_energie_chasse() -> float:
	return energie_chasse

func get_energie_fuite() -> float:
	return energie_fuite

func get_energie_chasse_max() -> float:
	return energie_chasse_max

func get_energie_fuite_max() -> float:
	return energie_fuite_max