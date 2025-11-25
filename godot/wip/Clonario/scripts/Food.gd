class_name Food
extends Area2D

var size

func _ready():
	randomize()
	$Sprite2D.modulate = Color8(randi_range(0, 255), randi_range(0, 255), randi_range(0, 255), 255)


func _on_body_entered(body: Node2D) -> void:
	var cell := body.get_node_or_null("Cell")
	if cell != null:
		print("Food eaten!")
		cell.grow(1)
		queue_free()