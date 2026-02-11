class_name MarqueurManager
extends Node

var marqueur_scene: PackedScene = preload("res://scenes/marqueur.tscn")
var marqueurs: Dictionary = {}  # {meteorite_id: marqueur_node}
var camera: Camera2D
var player: Node2D
var meteorites: Array = []

func _ready() -> void:
	camera = get_viewport().get_camera_2d()

func _process(_delta: float) -> void:
	if not camera or not player:
		return
	
	var camera_center = camera.get_screen_center_position()
	var viewport_size = camera.get_viewport_rect().size
	var camera_rect = Rect2(camera_center - viewport_size / 2, viewport_size)
	
	for meteorite in meteorites:
		var in_view = camera_rect.has_point(meteorite.global_position)
		var has_marker = marqueurs.has(meteorite)
		
		if not in_view and not has_marker:
			# Créer un marqueur
			_create_marker(meteorite)
		elif in_view and has_marker:
			# Supprimer le marqueur
			_remove_marker(meteorite)

func add_meteorite(meteorite: Meteorite) -> void:
	if meteorite not in meteorites:
		meteorites.append(meteorite)

func remove_meteorite(meteorite: Meteorite) -> void:
	meteorites.erase(meteorite)
	_remove_marker(meteorite)	

func _create_marker(meteorite: Meteorite) -> void:
	var marker = marqueur_scene.instantiate() as Marqueur
	add_child(marker)
	if (meteorite.is_brown()):
		marker.set_color("brown")
	else:
		marker.set_color("grey")
	marker.set_target(meteorite, player)
	marqueurs[meteorite] = marker

func _remove_marker(meteorite: Meteorite) -> void:
	if marqueurs.has(meteorite):
		marqueurs[meteorite].delete()
		marqueurs.erase(meteorite)