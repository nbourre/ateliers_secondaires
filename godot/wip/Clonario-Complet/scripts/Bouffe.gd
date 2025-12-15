class_name Bouffe
extends Area2D

signal eaten

var size

func _ready():
	randomize()
	$Sprite2D.modulate = Color8(randi_range(0, 255), randi_range(0, 255), randi_range(0, 255), 255)


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Cellule:
		var cell : Cellule = area.get_parent() as Cellule

		if cell != null:
			cell.grandir(1)
			eaten.emit(self)	
			#queue_free()

		
func disable() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	hide()

func enable() -> void:
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	show()