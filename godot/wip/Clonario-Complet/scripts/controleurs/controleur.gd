@abstract class_name Controleur
extends Node

signal change_state(message: String)

@abstract func get_mouvement() -> Vector2

# Renvoie ce que fait la cellule : "chasse", "fuite" ou "repos".
@abstract func get_comportement() -> String

# Donne le mouvement en tenant compte de l’énergie disponible.
@abstract func get_mouvement_avec_energie() -> Vector2

@abstract func mourir() -> void

	
