class_name MeteoritePool
extends ObjectPool

@export var player : Joueur = null

var sleeping := false

func _ready() -> void:
	scene_to_instance = preload("res://scenes/meteorite.tscn")
	super._ready()

# Obtient une instance du pool (réutilise ou crée)
func get_instance() -> Node:
	if (_available.size() > 0):
		var meteor = _available.pop_front() as Meteorite
		_in_use.append(meteor)
		_activate(meteor)
		meteor.pool = self
		return meteor
	else:
		# No more object available
		return null

# Libère une instance et la retourne au pool
func release_instance(instance : Node) -> void:
	(instance as Meteorite).reset()
	_deactivate(instance)
	_available.append(instance as Meteorite)
	_in_use.erase(instance as Meteorite)

func toggle_sleeping() -> void:
	sleeping = not sleeping
	set_sleeping(sleeping)

func sleep() -> void:
	sleeping = true
	

func awake() -> void:
	sleeping = false
	set_sleeping(sleeping)

func set_sleeping(sleeping_value: bool) -> void:
	for meteor in _in_use:
		meteor.sleeping = sleeping_value

# Retire tous les météorites en action
func reset() -> void:
	for meteor in _in_use:
		meteor.kill()