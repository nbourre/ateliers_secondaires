@abstract class_name Controleur
extends Node

@abstract func get_mouvement() -> Vector2

# Returns what the cell is doing: "chase", "flee", or "idle"
@abstract func get_comportement() -> String

# Get movement considering energy availability
@abstract func get_mouvement_avec_energie(peut_chasser: bool, peut_fuire: bool) -> Vector2

@abstract func mourir() -> void

	
