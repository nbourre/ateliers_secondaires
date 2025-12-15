@tool
class_name BarreProgression
extends TextureProgressBar

@export var afficher_etiquette : bool = true

@export var bar_name : String:
	get:
		return bar_name
	set(value):
		if value != bar_name:
			bar_name = value

@onready var etiquette : Label = $Texte

@export var couleur_progres : Color = Color(1,1,1):
	get:
		return tint_progress
	set(value):
		if value != tint_progress:
			tint_progress = value


func update_value (new_value : int, value_max : int):
	value_max = value_max
	value = new_value
	etiquette.text = str(bar_name, " : ", int(value), " / ", int (value_max))

func _process(_delta: float) -> void:
	_editor_management()
	
	if afficher_etiquette:
		etiquette.visible = true
	else:
		etiquette.visible = false

func _editor_management() -> void:
	if Engine.is_editor_hint():
		if etiquette != null:
			if afficher_etiquette:
				etiquette.visible = true
			else:
				etiquette.visible = false

			var temp_name := bar_name + " : " if bar_name != "" else ""
			etiquette.text = str(temp_name, int(value), "/" , int(max_value))
		
		tint_progress = couleur_progres
	
func set_couleur_progres(couleur: Color) -> void:
	tint_progress = couleur
	
