@abstract
class_name ObjectPool
extends Node

@export var pool_size : int = 10
@export var scene_to_instance : PackedScene
@export var prewarm: bool = true

var _available : Array[Node] = []
var _in_use : Array[Node] = []

func _ready() -> void:
	if prewarm:
		_prewarm()

# Préchauffage du pool : crée et désactive les instances au démarrage
func _prewarm() -> void:
	for i in range(pool_size):
		var instance = scene_to_instance.instantiate()
		#add_child(instance)
		_deactivate(instance)
		_available.append(instance)

# Active un objet : rend visible, active les processus
func _activate(obj : Node) -> void:
	if obj is CanvasItem:
		(obj as CanvasItem).visible = true
	obj.set_process(true)
	obj.set_physics_process(true)
	if obj.get_parent() != self:
		add_child(obj)

# Désactive un objet : cache, désactive les processus
func _deactivate(obj : Node) -> void:
	if obj is CanvasItem:
		(obj as CanvasItem).visible = false
	obj.set_process(false)
	obj.set_physics_process(false)
	if obj.get_parent() == self:
		call_deferred("remove_child", obj)


@abstract func get_instance() -> Node
@abstract func release_instance(instance : Node) -> void

