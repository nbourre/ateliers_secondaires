class_name ControleurJoueur
extends Controleur

var direction := Vector2.ZERO
var dir_stop := 150.0

# Vitesses pour différents modes
var vitesse_normale := 4000.0
var vitesse_chasse := 6000.0
var vitesse_fuite := 8000.0

# État actuel du joueur
var mode_chasse := false
var mode_fuite := false

var vecteur_deplacement := Vector2.ZERO

var ma_cellule : Cellule

func _ready() -> void:
	ma_cellule = get_parent() as Cellule

func get_mouvement() -> Vector2:
	return vecteur_deplacement

func get_comportement() -> String:
	# Retourner le comportement actuel basé sur les touches pressées
	if mode_fuite:
		return "fuite"
	elif mode_chasse:
		return "chasse"
	else:
		return "repos"

func get_mouvement_avec_energie(peut_chasser: bool, peut_fuir: bool) -> Vector2:
	var multiplicateur_dim := ma_cellule.get_multiplicateur_vitesse()
	var multiplicateur_energie := 1.0
	
	# Si le joueur n'a plus d'énergie, ralentir!
	if mode_chasse and not peut_chasser:
		multiplicateur_energie = 0.5  # Moitié vitesse quand fatigué
	elif mode_fuite and not peut_fuir:
		multiplicateur_energie = 0.3  # Très lent quand impossible de fuir!
	
	var multiplicateur_total := multiplicateur_dim * multiplicateur_energie
	
	return vecteur_deplacement * multiplicateur_total

func mourir() -> void:
	get_tree().reload_current_scene()

# Returns a normalized vector pointing from the center of the screen to the mouse position
func get_direction_souris() -> Vector2:
	#var mouse_global := DisplayServer.mouse_get_position() as Vector2
	var mouse_vp := get_viewport().get_mouse_position()
	var screen_center := get_viewport().get_visible_rect().size / 2
	var dir := mouse_vp - screen_center
	
	return dir


func _process(delta: float) -> void:
	# Vérifier les touches pour chasse et fuite
	mode_chasse = Input.is_action_pressed("chasse")
	mode_fuite = Input.is_action_pressed("fuite")
	
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
