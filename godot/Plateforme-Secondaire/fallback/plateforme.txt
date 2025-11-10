@tool
extends AnimatableBody2D

@export_enum("gazon", "sec", "jaune", "glace") var type : int = 0
		
		
@onready var sprite : Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.region_rect.position.y = type * 16

	pass # Replace with function body.

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		$Sprite2D.region_rect.position.y = type * 16
