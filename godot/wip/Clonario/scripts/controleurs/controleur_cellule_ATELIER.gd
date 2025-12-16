# Contrôleur IA pour les cellules non jouables.
class_name ControleurCellule
extends Controleur

# region ETATS IA
enum Etat {
	INACTIF,
	BOUGE,
	BROUTE,
	CHASSE,
	FUITE
}

var etat_actuel: Etat = Etat.INACTIF
# endregion ETATS IA

var tous_objets_mangeables := []

var direction: Vector2 = Vector2.ZERO

var temps_inactif: float = 0.0

var deplacement_premiere_fois: bool = true
var deplacement_temps: float = 0.0
var deplacement_vitesse: float = 6000.0

var broute_premiere_fois: bool = true
var broute_temps: float = 0.0
var broute_vitesse: float = 3000.0  # Plus lent quand on broute (mange)
@export var broute_rayon_arret: float = 40.0  # Distance pour cesser d'avancer et éviter le ping-pong près de la bouffe

var chasse_premiere_fois: bool = true
var chasse_temps: float = 0.0
var chasse_vitesse: float = 8000.0

var fuite_premiere_fois: bool = true
var fuite_vitesse: float = 10000.0

# Système d'énergie du contrôleur IA
@export var energie_chasse_max := 5.0
@export var energie_fuite_max := 3.0
@export var vitesse_recharge_chasse := 1.0
@export var vitesse_recharge_fuite := 2.0

var energie_chasse := energie_chasse_max
var energie_fuite := energie_fuite_max

var multiplicateur_energie := 1.0

var vecteur_deplacement: Vector2 = Vector2.ZERO

var objet_plus_proche: Node2D = null
var bouffe_cible: Bouffe = null

@export var chasse_distance: float = 800.0
@export var fuite_distance: float = 400.0
@export var mode_deboggage: bool = false

var ma_cellule : Cellule

# region Déboggage
var deboggage_formes : Array[DebugShape] = []

# Couleurs de déboggage
var couleur_chasse := Color(0, 1, 0, 0.2)  # Vert
var couleur_fuite := Color(1, 0, 0, 0.3)   # Rouge

func ajout_formes_deboggage() -> void:
	var fleche_direction := DebugShape.new()
	ma_cellule.add_child(fleche_direction)
	fleche_direction.set_shape_type (DebugShape.ShapeType.ARROW)
	fleche_direction.set_position(ma_cellule.position)
	fleche_direction.size = fuite_distance

	deboggage_formes.append(fleche_direction)

func set_debug_mode(enabled : bool) -> void:
	mode_deboggage = enabled
	if not mode_deboggage:
		ma_cellule.update()  # Efface les anciens dessins de déboggage

func _draw() -> void:
	if not mode_deboggage:
		return
	
	for shape in deboggage_formes:
		shape.rotation = direction.angle()
		pass

func afficher_etat_cellule(number : int) -> void:

	if not (ma_cellule.name.ends_with(str(number))):
		return

	var etat_str := get_comportement()

	print ("Cellule " + str(number) + 
		" | État: " + etat_str +
		" | Énergie Chasse: " + str(energie_chasse) + "/" + str(energie_chasse_max) +
		" | Énergie Fuite: " + str(energie_fuite) + "/" + str(energie_fuite_max) +
		" | Position: " + str(ma_cellule.position)
	)
	

# endregion Déboggage


# Point d'entrée : on prépare l'état et on récupère la cellule parente.
func _ready() -> void:
	etat_actuel = Etat.INACTIF
	set_process(true)
	ma_cellule = get_parent() as Cellule

	if mode_deboggage:
		ajout_formes_deboggage()

# Boucle principale : met à jour l'IA chaque frame.
func _process(delta: float) -> void:
	gestion_intelligence(delta)
	
	_draw()



func get_mouvement() -> Vector2:
	return vecteur_deplacement

func get_comportement() -> String:
	match etat_actuel:
		Etat.CHASSE:
			return "chasse"
		Etat.FUITE:
			return "fuite"
		Etat.BROUTE:
			return "broute"
		_:
			return "inactif"

func mise_a_jour_energie(delta: float) -> void:
	multiplicateur_energie = 1.0
	match etat_actuel:
		Etat.CHASSE:
			if energie_chasse > 0.0:
				energie_chasse = max(0.0, energie_chasse - delta)
			else:
				multiplicateur_energie = 0.5
		Etat.FUITE:
			if energie_fuite > 0.0:
				energie_fuite = max(0.0, energie_fuite - delta)
			else:
				multiplicateur_energie = 0.3
		Etat.BROUTE:
			energie_chasse = min(energie_chasse_max, energie_chasse + vitesse_recharge_chasse * delta)
			energie_fuite = min(energie_fuite_max, energie_fuite + vitesse_recharge_fuite * delta)
		_:
			energie_chasse = min(energie_chasse_max, energie_chasse + vitesse_recharge_chasse * delta)
			energie_fuite = min(energie_fuite_max, energie_fuite + vitesse_recharge_fuite * delta)

func get_mouvement_avec_energie() -> Vector2:
	# Ici, l'énergie est déjà appliquée dans vecteur_deplacement.
	# On applique seulement le multiplicateur de vitesse lié à la taille.
	var multiplicateur_dim := ma_cellule.get_multiplicateur_vitesse()
	return vecteur_deplacement * multiplicateur_dim

func mourir() -> void:
	get_parent().queue_free()
	print("La cellule est morte.")

func set_tous_objets_mangeables(objects : Array) -> void:
	tous_objets_mangeables = objects

func gestion_intelligence(delta : float) -> void:
	match etat_actuel:
		Etat.INACTIF:
			etat_inactif(delta)
		Etat.BOUGE:
			etat_bouge(delta)
		Etat.BROUTE:
			etat_broute(delta)
		Etat.CHASSE:
			etat_chasse(delta)
		Etat.FUITE:
			etat_fuite(delta)
	
	# Rafraîchit le visuel de déboggage pour suivre la direction.
	if mode_deboggage:
		ma_cellule.queue_redraw()

# region États IA

func etat_inactif(delta : float) -> void:
	mise_a_jour_energie(delta)
	vecteur_deplacement = Vector2.ZERO

	temps_inactif += delta
	if temps_inactif > 3.0:
		etat_actuel = Etat.BOUGE
		temps_inactif = 0.0


func etat_bouge(delta : float) -> void:
	mise_a_jour_energie(delta)
	deplacement_temps += delta
	if deplacement_premiere_fois:
		deplacement_premiere_fois = false
		direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	
	if deplacement_temps > randf() * 3.0 + 2.0:
		direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		deplacement_temps = 0.0
	
	vecteur_deplacement = direction * deplacement_vitesse * multiplicateur_energie * delta

	# Priorité : vérifier les menaces avant tout.
	var threat = trouve_menace_proche()
	if threat != null:
		var distance_to_threat = ma_cellule.global_position.distance_to(threat.global_position)
		if distance_to_threat < fuite_distance:
			objet_plus_proche = threat
			etat_actuel = Etat.FUITE
			deplacement_premiere_fois = true
			deplacement_temps = 0.0
			return


	# Puis chercher une proie plus petite à pourchasser.
	var prey = trouve_proie_plus_petite()
	if prey != null:
		var distance_to_prey = ma_cellule.global_position.distance_to(prey.global_position)
		if distance_to_prey < chasse_distance:
			objet_plus_proche = prey
			etat_actuel = Etat.CHASSE
			deplacement_premiere_fois = true
			deplacement_temps = 0.0
			return
	
	# Enfin, chercher de la bouffe à brouter.
	var food = trouve_bouffe_proche()
	if food != null:
		var distance_to_food = ma_cellule.global_position.distance_to(food.global_position)
		if distance_to_food < chasse_distance:
			objet_plus_proche = food
			etat_actuel = Etat.BROUTE
			deplacement_premiere_fois = true
			broute_premiere_fois = true
			deplacement_temps = 0.0
			return


func etat_broute(delta : float) -> void:
	mise_a_jour_energie(delta)
	broute_temps += delta

	if broute_premiere_fois:
		broute_premiere_fois = false
	
	# Pendant qu'on mange, on surveille les menaces et on fuit si besoin.
	var threat = trouve_menace_proche()
	if threat != null:
		var distance_to_threat = ma_cellule.global_position.distance_to(threat.global_position)
		if distance_to_threat < fuite_distance:
			objet_plus_proche = threat
			bouffe_cible = null
			etat_actuel = Etat.FUITE
			broute_premiere_fois = true
			broute_temps = 0.0
			return

	# Toujours cibler la bouffe la plus proche.
	bouffe_cible = trouve_bouffe_proche()

	if bouffe_cible == null or not is_instance_valid(bouffe_cible):
		# Pas de bouffe trouvée ou elle a disparu, retour errer.
		etat_actuel = Etat.BOUGE
		broute_premiere_fois = true
		broute_temps = 0.0
		vecteur_deplacement = Vector2.ZERO
		return

	var direction_vers_bouffe: Vector2 = bouffe_cible.global_position - ma_cellule.global_position
	if direction_vers_bouffe.length() <= 0.001:
		vecteur_deplacement = Vector2.ZERO
		return

	direction = direction_vers_bouffe.normalized()
	vecteur_deplacement = direction * broute_vitesse * multiplicateur_energie * delta

func etat_chasse(delta : float) -> void:
	mise_a_jour_energie(delta)

	chasse_temps += delta

	if chasse_premiere_fois:
		chasse_premiere_fois = false
		var msg := ma_cellule.name + " commence à chasser " + str(objet_plus_proche.name)
		print(msg)
		change_state.emit(msg)
	
	# Même en chasse, on surveille les gros dangers.
	var menace = trouve_menace_proche()
	if menace != null:
		var distance_menace = ma_cellule.global_position.distance_to(menace.global_position)
		if distance_menace < fuite_distance:
			objet_plus_proche = menace
			etat_actuel = Etat.FUITE
			chasse_premiere_fois = true
			chasse_temps = 0.0
			return
	
	# Met à jour la proie la plus proche (doit être plus petite).
	var proie = trouve_proie_plus_petite()
	if proie != null:
		objet_plus_proche = proie
		var distance_proie = ma_cellule.global_position.distance_to(proie.global_position)
		
		# Si la proie est trop loin, on arrête la chasse.
		if distance_proie > chasse_distance * 1.5:
			etat_actuel = Etat.BOUGE
			chasse_premiere_fois = true
			chasse_temps = 0.0
			return
		
		# Avance vers la proie.
		direction = (proie.global_position - ma_cellule.global_position).normalized()
		vecteur_deplacement = direction * chasse_vitesse * multiplicateur_energie * delta
	else:
		# Plus de proie, on retourne errer.
		etat_actuel = Etat.BOUGE
		chasse_premiere_fois = true
		chasse_temps = 0.0

# ============================================================================
# ATELIER : PROGRAMMATION DE L'ÉTAT FUITE
# ============================================================================
# OBJECTIF: Faire fuir la cellule lorsqu'elle détecte une cellule plus grosse
# 
# CONSIGNES:
# 1. Mettre à jour l'énergie de fuite
# 2. Si c'est la première fois en fuite, afficher un message de debug
# 3. Trouver la menace la plus proche
# 4. Si une menace existe:
#    a) Calculer la distance entre la cellule et la menace
#    b) Si la menace est trop loin (> fuite_distance * 1.5), retourner en BOUGE
#    c) Sinon, calculer la direction OPPOSÉE à la menace
#    d) Appliquer le mouvement de fuite
# 5. Si aucune menace, retourner en mode BOUGE
#
# VARIABLES UTILES:
# - ma_cellule.global_position : position de la cellule
# - menace.global_position : position de la menace
# - fuite_distance : distance maximale de détection
# - fuite_vitesse : vitesse de fuite
# - multiplicateur_energie : facteur d'énergie
# - delta : temps écoulé depuis la dernière frame
#
# FONCTIONS UTILES:
# - mise_a_jour_energie(delta) : met à jour l'énergie
# - trouve_menace_proche() : trouve la cellule menaçante la plus proche
# - Vector2.distance_to() : calcule la distance entre deux points
# - Vector2.normalized() : normalise un vecteur (longueur = 1)
# ============================================================================

func etat_fuite(delta : float) -> void:
	# TODO: Compléter cette fonction
	
	# Version temporaire pour que le jeu reste fonctionnel:
	# Les cellules s'arrêtent brièvement puis retournent en BOUGE
	mise_a_jour_energie(delta)
	vecteur_deplacement = Vector2.ZERO
	
	if fuite_premiere_fois:
		fuite_premiere_fois = false
		# Timer de 1 seconde avant de retourner en BOUGE
		await get_tree().create_timer(1.0).timeout
		if etat_actuel == Etat.FUITE:
			etat_actuel = Etat.BOUGE
			fuite_premiere_fois = true


# ============================================================================
# CODE SOLUTION (à décommenter une fois votre code testé):
# ============================================================================
#func etat_fuite(delta : float) -> void:
#	# 1. Mettre à jour l'énergie
#	mise_a_jour_energie(delta)
#	
#	# 2. Message de debug si première fois
#	if fuite_premiere_fois:
#		fuite_premiere_fois = false
#		var msg := ma_cellule.name + " fuit " + str(objet_plus_proche.name)
#		print(msg)
#		change_state.emit(msg)
#	
#	# 3. Trouver la menace la plus proche
#	var menace = trouve_menace_proche()
#	
#	# 4. Si une menace existe
#	if menace != null:
#		# a) Calculer la distance
#		var distance_menace = ma_cellule.global_position.distance_to(menace.global_position)
#		
#		# b) Si trop loin, retourner en BOUGE
#		if distance_menace > fuite_distance * 1.5:
#			etat_actuel = Etat.BOUGE
#			fuite_premiere_fois = true
#			return
#		
#		# c) Calculer la direction opposée (position_cellule - position_menace)
#		direction = (ma_cellule.global_position - menace.global_position).normalized()
#		
#		# d) Appliquer le mouvement
#		vecteur_deplacement = direction * fuite_vitesse * multiplicateur_energie * delta
#	else:
#		# 5. Aucune menace, retourner en BOUGE
#		etat_actuel = Etat.BOUGE
#		fuite_premiere_fois = true

# endregion États IA

# region Fonctions de recherche d'objets

func trouve_bouffe_plus_proche() -> Node2D:
	var distance_plus_proche: float = INF
	
	for obj in tous_objets_mangeables:
		if obj is Node2D:
			var dist = ma_cellule.global_position.distance_to(obj.global_position)
			if dist < distance_plus_proche:
				distance_plus_proche = dist
				objet_plus_proche = obj
	
	return objet_plus_proche

func trouve_proie_proche() -> Node2D:
	var proie_plus_proche: Node2D = null
	var distance_plus_proche: float = INF
	
	if ma_cellule == null:
		return null
	
	for obj in tous_objets_mangeables:
		if obj == null or not is_instance_valid(obj):
			continue
		
		var is_prey := false
		
		# Bouffe = toujours une proie.
		if obj is Bouffe:
			is_prey = true
		# Cellule plus petite = proie possible.
		elif obj is Cellule:
			var other_cell = obj as Cellule
			if other_cell.get_dimension() < ma_cellule.get_dimension() * 0.8:
				is_prey = true
		
		if is_prey:
			var dist = ma_cellule.global_position.distance_to(obj.global_position)
			if dist < distance_plus_proche:
				distance_plus_proche = dist
				proie_plus_proche = obj
	
	return proie_plus_proche

func trouve_menace_proche() -> Node2D:
	var menace_proche: Node2D = null
	var distance_plus_proche: float = INF
	
	if ma_cellule == null:
		return null
	
	for obj in tous_objets_mangeables:
		if obj == null or not is_instance_valid(obj):
			continue
		
		# Seules les cellules plus grosses peuvent être une menace.
		if obj is Cellule:
			var autre_cellule = obj as Cellule
			if autre_cellule.get_dimension() > ma_cellule.get_dimension() * 1.25:
				var dist = ma_cellule.global_position.distance_to(obj.global_position)
				if dist < distance_plus_proche:
					distance_plus_proche = dist
					menace_proche = obj
	
	return menace_proche

func trouve_bouffe_proche() -> Bouffe:
	var bouffe_proche: Bouffe = null
	var distance_plus_proche: float = INF
	
	if ma_cellule == null:
		return null
	
	for obj in tous_objets_mangeables:
		if obj == null or not is_instance_valid(obj):
			continue
		
		# On ne garde que les objets de type Bouffe.
		if obj is Bouffe:
			var dist = ma_cellule.global_position.distance_to(obj.global_position)
			if dist < distance_plus_proche:
				distance_plus_proche = dist
				bouffe_proche = obj
	
	return bouffe_proche

func trouve_proie_plus_petite() -> Node2D:
	var cellule_plus_proche: Node2D = null
	var distance_plus_proche: float = INF
	
	if ma_cellule == null:
		return null
	
	for obj in tous_objets_mangeables:
		if obj == null or not is_instance_valid(obj):
			continue
		
		# On ne cible que les cellules plus petites que nous.
		if obj is Cellule:
			var autre_cellule = obj as Cellule
			if autre_cellule.get_dimension() < ma_cellule.get_dimension():
				var dist = ma_cellule.global_position.distance_to(obj.global_position)
				if dist < distance_plus_proche:
					distance_plus_proche = dist
					cellule_plus_proche = obj
	
	return cellule_plus_proche

# endregion Fonctions de recherche d'objets

func get_energie_chasse() -> float:
	return energie_chasse

func get_energie_fuite() -> float:
	return energie_fuite

func get_energie_chasse_max() -> float:
	return energie_chasse_max

func get_energie_fuite_max() -> float:
	return energie_fuite_max
