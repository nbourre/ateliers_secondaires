class_name ExplosionVaisseau
extends Node2D

var activation := false

@onready var particles := $GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func activer() -> void:
	particles.emitting = true