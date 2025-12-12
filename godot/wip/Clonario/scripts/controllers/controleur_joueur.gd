class_name ControleurJoueur
extends Controleur

var direction := Vector2.ZERO
var dir_stop := 150.0

var vitesse := 6000.0

func get_mouvement() -> Vector2:
	return direction

func get_comportement() -> String:
	# Joueur is always in "idle" mode (no energy system for player)
	return "idle"

func get_mouvement_avec_energie(_can_chase: bool, _can_flee: bool) -> Vector2:
	# Joueur doesn't use energy system
	return direction

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
	
	var dir := get_direction_souris()

	if dir.length() < dir_stop:
		# FIXME: Not stopping
		direction = direction.lerp(Vector2.ZERO, 0.1)
		#print("Stopping")
	else:
		direction = direction.lerp(dir.normalized() * vitesse * delta, 0.1)
