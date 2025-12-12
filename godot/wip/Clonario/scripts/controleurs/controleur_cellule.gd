# This is the AI controller for non-player cells.
class_name ControleurCellule
extends Controleur

enum Etat {
	INACTIF,
	BOUGE,
	BROUTE,
	CHASSE,
	FUITE
}

var etat_actuel: Etat = Etat.INACTIF

var tous_objets_mangeables := []

var direction: Vector2 = Vector2.ZERO

var temps_inactif: float = 0.0

var deplacement_premiere_fois: bool = true
var deplacement_temps: float = 0.0
var deplacement_vitesse: float = 4000.0

var broute_premiere_fois: bool = true
var broute_temps: float = 0.0
var broute_vitesse: float = 2000.0  # Slower when grazing (eating food)

var chasse_premiere_fois: bool = true
var chasse_temps: float = 0.0
var chasse_vitesse: float = 6000.0

var fuite_vitesse: float = 8000.0

var vecteur_deplacement: Vector2 = Vector2.ZERO

var objet_plus_proche: Node2D = null

@export var chasse_distance: float = 800.0
@export var fuite_distance: float = 400.0
@export var mode_deboggage: bool = false

var deboggage_formes : Array[DebugShape] = []

# Couleurs de déboggage
var couleur_chasse := Color(0, 1, 0, 0.2)  # Green
var couleur_fuite := Color(1, 0, 0, 0.3)   # Red

var ma_cellule : Cellule

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	etat_actuel = Etat.INACTIF
	set_process(true)
	ma_cellule = get_parent() as Cellule

	if mode_deboggage:
		ajout_formes_deboggage()

func ajout_formes_deboggage() -> void:
	var fleche_direction := DebugShape.new()
	ma_cellule.add_child(fleche_direction)
	fleche_direction.set_shape_type (DebugShape.ShapeType.ARROW)
	fleche_direction.set_position(ma_cellule.position)
	fleche_direction.size = fuite_distance

	deboggage_formes.append(fleche_direction)
#	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	state_manager(delta)
	
	_draw()

func _draw() -> void:
	if not mode_deboggage:
		return
	
	for shape in deboggage_formes:
		shape.rotation = direction.angle()
		pass

func get_mouvement() -> Vector2:
	return vecteur_deplacement

func get_comportement() -> String:
	# Tell the cell what we're doing so it can manage energy
	match etat_actuel:
		Etat.CHASSE:
			return "chasse"
		Etat.FUITE:
			return "fuite"
		Etat.BROUTE:
			return "broute"
		_:
			return "inactif"

func get_mouvement_avec_energie(can_chase: bool, can_flee: bool) -> Vector2:
	var size_multiplier := ma_cellule.get_multiplicateur_vitesse()
	var energy_multiplier := 1.0

	# If out of energy, slow down!
	if etat_actuel == Etat.CHASSE and not can_chase:
		energy_multiplier = 0.5  # Half speed when tired
	elif etat_actuel == Etat.FUITE and not can_flee:
		energy_multiplier = 0.3  # Very slow when can't flee!
	
	var total_multiplier := size_multiplier * energy_multiplier

	return vecteur_deplacement * total_multiplier

func mourir() -> void:
	get_parent().queue_free()
	print("Cellule has died.")

func set_tous_objets_mangeables(objects : Array) -> void:
	tous_objets_mangeables = objects

func state_manager(delta : float) -> void:
	match etat_actuel:
		Etat.INACTIF:
			idle_state(delta)
		Etat.BOUGE:
			move_state(delta)
		Etat.BROUTE:
			graze_state(delta)
		Etat.CHASSE:
			chase_state(delta)
		Etat.FUITE:
			flee_state(delta)
	
	# Update debug visualization
	if mode_deboggage:
		ma_cellule.queue_redraw()

func idle_state(delta : float) -> void:
	temps_inactif += delta
	if temps_inactif > 3.0:
		etat_actuel = Etat.BOUGE
		temps_inactif = 0.0

func set_debug_mode(enabled : bool) -> void:
	mode_deboggage = enabled
	if not mode_deboggage:
		ma_cellule.update()  # Clear any existing drawings

func move_state(delta : float) -> void:
	deplacement_temps += delta
	if deplacement_premiere_fois:
		deplacement_premiere_fois = false
		direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	
	if deplacement_temps > 5.0:
		direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		deplacement_temps = 0.0
	
	vecteur_deplacement = direction * deplacement_vitesse * delta

	# Check for threats first (priority!)
	var threat = find_closest_threat()
	if threat != null:
		var distance_to_threat = get_parent().position.distance_to(threat.position)
		if distance_to_threat < fuite_distance:
			objet_plus_proche = threat
			etat_actuel = Etat.FUITE
			deplacement_premiere_fois = true
			deplacement_temps = 0.0
			return

	# Look for food to graze on
	var food = find_closest_food()
	if food != null:
		var distance_to_food = get_parent().position.distance_to(food.position)
		if distance_to_food < chasse_distance:
			objet_plus_proche = food
			etat_actuel = Etat.BROUTE
			deplacement_premiere_fois = true
			broute_premiere_fois = true
			deplacement_temps = 0.0
			return
	
	# Check for prey (smaller cells) to chase
	var prey = find_closest_smaller_cell()
	if prey != null:
		var distance_to_prey = get_parent().position.distance_to(prey.position)
		if distance_to_prey < chasse_distance:
			objet_plus_proche = prey
			etat_actuel = Etat.CHASSE
			deplacement_premiere_fois = true
			deplacement_temps = 0.0
			return

func graze_state(delta : float) -> void:
	broute_temps += delta
	if broute_premiere_fois:
		broute_premiere_fois = false
	
	# Check for threats while grazing (stop eating and flee!)
	var threat = find_closest_threat()
	if threat != null:
		var distance_to_threat = get_parent().position.distance_to(threat.position)
		if distance_to_threat < fuite_distance:
			objet_plus_proche = threat
			etat_actuel = Etat.FUITE
			broute_premiere_fois = true
			broute_temps = 0.0
			return
	
	# Look for food to graze on
	var food = find_closest_food()
	if food != null:
		objet_plus_proche = food
		var distance_to_food = get_parent().position.distance_to(food.position)
		
		# If food is too far, go back to move state
		if distance_to_food > chasse_distance * 1.5:
			etat_actuel = Etat.BOUGE
			broute_premiere_fois = true
			broute_temps = 0.0
			return
		
		# Move towards food slowly
		direction = (food.position - get_parent().position).normalized()
		vecteur_deplacement = direction * broute_vitesse * delta
	else:
		# No more food, go back to move state
		etat_actuel = Etat.BOUGE
		broute_premiere_fois = true
		broute_temps = 0.0

func chase_state(delta : float) -> void:
	chasse_temps += delta
	if chasse_premiere_fois:
		chasse_premiere_fois = false
	
	# Check if a threat is nearby while chasing
	var threat = find_closest_threat()
	if threat != null:
		var distance_to_threat = get_parent().position.distance_to(threat.position)
		if distance_to_threat < fuite_distance:
			objet_plus_proche = threat
			etat_actuel = Etat.FUITE
			chasse_premiere_fois = true
			chasse_temps = 0.0
			return
	
	# Update closest prey (smaller cells only)
	var prey = find_closest_smaller_cell()
	if prey != null:
		objet_plus_proche = prey
		var distance_to_prey = get_parent().position.distance_to(prey.position)
		
		# If prey is too far, go back to move state
		if distance_to_prey > chasse_distance * 1.5:
			etat_actuel = Etat.BOUGE
			chasse_premiere_fois = true
			chasse_temps = 0.0
			return
		
		# Move towards prey
		direction = (prey.position - get_parent().position).normalized()
		vecteur_deplacement = direction * chasse_vitesse * delta
	else:
		# No more prey, go back to move state
		etat_actuel = Etat.BOUGE
		chasse_premiere_fois = true
		chasse_temps = 0.0

func flee_state(delta : float) -> void:
	var threat = find_closest_threat()
	if threat != null:
		var distance_to_threat = get_parent().position.distance_to(threat.position)
		
		# If threat is far enough, go back to move state
		if distance_to_threat > fuite_distance * 1.5:
			etat_actuel = Etat.BOUGE
			return
		
		# Move away from threat
		direction = (get_parent().position - threat.position).normalized()
		vecteur_deplacement = direction * fuite_vitesse * delta
	else:
		# No more threats, go back to move state
		etat_actuel = Etat.BOUGE

func find_closest_eatable_object() -> Node2D:
	var closest_object: Node2D = null
	var closest_distance: float = INF
	
	for obj in tous_objets_mangeables:
		if obj is Node2D:
			var dist = get_parent().position.distance_to(obj.position)
			if dist < closest_distance:
				closest_distance = dist
				closest_object = obj
	
	return closest_object

func find_closest_prey() -> Node2D:
	var closest_prey: Node2D = null
	var closest_distance: float = INF
	
	if ma_cellule == null:
		return null
	
	for obj in tous_objets_mangeables:
		if obj == null or not is_instance_valid(obj):
			continue
		
		var is_prey := false
		
		# Check if it's food
		if obj is Bouffe:
			is_prey = true
		# Check if it's a smaller cell
		elif obj is Cellule:
			var other_cell = obj as Cellule
			if other_cell.get_dimension() < ma_cellule.get_dimension() * 0.8:
				is_prey = true
		
		if is_prey:
			var dist = ma_cellule.position.distance_to(obj.position)
			if dist < closest_distance:
				closest_distance = dist
				closest_prey = obj
	
	return closest_prey

func find_closest_threat() -> Node2D:
	var closest_threat: Node2D = null
	var closest_distance: float = INF
	
	if ma_cellule == null:
		return null
	
	for obj in tous_objets_mangeables:
		if obj == null or not is_instance_valid(obj):
			continue
		
		# Only cells can be threats
		if obj is Cellule:
			var other_cell = obj as Cellule
			if other_cell.get_dimension() > ma_cellule.get_dimension() * 1.25:
				var dist = ma_cellule.position.distance_to(obj.position)
				if dist < closest_distance:
					closest_distance = dist
					closest_threat = obj
	
	return closest_threat

func find_closest_food() -> Node2D:
	var closest_food: Node2D = null
	var closest_distance: float = INF
	
	if ma_cellule == null:
		return null
	
	for obj in tous_objets_mangeables:
		if obj == null or not is_instance_valid(obj):
			continue
		
		# Only look for Bouffe objects
		if obj is Bouffe:
			var dist = ma_cellule.position.distance_to(obj.position)
			if dist < closest_distance:
				closest_distance = dist
				closest_food = obj
	
	return closest_food

func find_closest_smaller_cell() -> Node2D:
	var closest_cell: Node2D = null
	var closest_distance: float = INF
	
	if ma_cellule == null:
		return null
	
	for obj in tous_objets_mangeables:
		if obj == null or not is_instance_valid(obj):
			continue
		
		# Only look for smaller cells
		if obj is Cellule:
			var other_cell = obj as Cellule
			if other_cell.get_dimension() < ma_cellule.get_dimension():
				var dist = ma_cellule.position.distance_to(obj.position)
				if dist < closest_distance:
					closest_distance = dist
					closest_cell = obj
	
	return closest_cell
