@abstract class_name Controleur
extends Node

@abstract func get_movement() -> Vector2

# Returns what the cell is doing: "chase", "flee", or "idle"
@abstract func get_behavior() -> String

# Get movement considering energy availability
@abstract func get_movement_with_energy(can_chase: bool, can_flee: bool) -> Vector2

@abstract func die() -> void

	
