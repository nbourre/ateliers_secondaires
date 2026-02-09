extends Node2D

var meteorite_scene : PackedScene = preload("res://scenes/Meteorite.tscn")
var meteorite_pool : Array = []

@onready var spawner := $Spawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawner.connect("new_spawn_ready", Callable(self, "_on_new_spawn_ready"))
	spawner.autospawn = true

func _on_new_spawn_ready(position: Vector2) -> void:
	print("New spawn at: ", position)
	spawn_meteorite(position)


func spawn_meteorite(position: Vector2) -> void:
	var meteorite = meteorite_scene.instantiate()
	meteorite.position = position
	add_child(meteorite)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
