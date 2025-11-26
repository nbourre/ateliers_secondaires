class_name Food
extends Area2D

var size

func _ready():
	randomize()
	$Sprite2D.modulate = Color8(randi_range(0, 255), randi_range(0, 255), randi_range(0, 255), 255)


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Cell:
		var cell : Cell = area.get_parent() as Cell

		if cell != null:
			print("Food eaten!")
			cell.grow(1)
			queue_free()