extends ProgressBar
class_name GenericBar

@export var bar_name : String
@export var show_text : bool = true
@onready var text : Label = $BarText

func _ready():
	text.visible = show_text

func update_value (new_value, _max):
	if _max != null :
		max_value = _max
	value = new_value		
	
