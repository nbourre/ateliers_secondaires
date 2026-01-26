extends Node2D

signal body_entered(body: Node2D)

var sprite_names: Array = []
@onready var sprite := $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_sprite_names()
	set_random_sprite()

func load_sprite_names():
	var folder := "res://assets/sprites/meteors/"
	var dir := DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".png"):
					var filename := folder + file_name
					sprite_names.append(filename)
			file_name = dir.get_next()
		dir.list_dir_end()

func set_random_sprite() -> void:
	var random_index := randi() % sprite_names.size()
	var texture := load(sprite_names[random_index]) as Texture2D
	sprite.texture = texture

# Lorsqu'un corps entre dans la zone de collision
func _on_area_2d_body_entered(body: Node2D) -> void:
	emit_signal("body_entered", body)
	print("Météorite touchée par: %s" % body.name)
