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
	
func _prewarm() -> void:
	for i in range(pool_size):
		var instance = scene_to_instance.instantiate()
		_deactivate(instance)
		_available.append(instance)
		
# Default activation behavior (override if you want)
func _activate(obj : Node) -> void:
	if obj is CanvasItem:
		(obj as CanvasItem).visible = true
	obj.set_process(true)
	obj.set_physics_process(true)

func _deactivate(obj : Node) -> void:
	if obj is CanvasItem:
		(obj as CanvasItem).visible = false
	obj.set_process(false)
	obj.set_physics_process(false)


@abstract func get_instance() -> Node
@abstract func release_instance(instance : Node) -> void

