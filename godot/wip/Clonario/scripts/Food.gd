class_name Food
extends Area2D

var size

func _ready():
	randomize()
	size = randf_range(0.5, 1.5)
	$MeshInstance2D.scale = Vector2(size, size)
	$CollisionShape2D.scale = Vector2(size, size)
	$MeshInstance2D.modulate = Color8(randi_range(0, 255), randi_range(0, 255), randi_range(0, 255), 255)
	
