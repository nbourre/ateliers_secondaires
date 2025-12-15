@abstract class_name Controleur
extends Node

signal change_state(message: String)

@abstract func get_mouvement() -> Vector2

# Donne le mouvement en tenant compte de l’énergie disponible.
@abstract func get_mouvement_avec_energie() -> Vector2

@abstract func mourir() -> void

	
