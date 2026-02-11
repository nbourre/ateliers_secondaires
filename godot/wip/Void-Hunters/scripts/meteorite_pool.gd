class_name MeteoritePool
extends ObjectPool

@export var player : Joueur = null

func _ready() -> void:
    scene_to_instance = preload("res://scenes/Meteorite.tscn")
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
        # return null
        return null

# Libère une instance et la retourne au pool
func release_instance(instance : Node) -> void:
    reset(instance as Meteorite)
    _deactivate(instance)
    _available.append(instance as Meteorite)
    _in_use.erase(instance as Meteorite)

# Réinitialise l'état d'une météorite
func reset(m : Meteorite) -> void:
    m.reset()



