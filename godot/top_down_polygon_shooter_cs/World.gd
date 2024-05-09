extends Node2D
class_name World

@export var mob_scene : PackedScene
@onready var hud : HUD

var max_mobs = 14

func _ready():
	if has_node("HUD"):
		hud = $HUD
		
	if has_node("MobTimer"):
		($MobTimer as Timer).timeout.connect(_on_mob_timer_timeout)
	
	load_game()

func start_spawning():
	if has_node("MobTimer"):
		$MobTimer.start()

func _on_mob_timer_timeout():
	if has_node("Level"):
		if Enemy.count > max_mobs : return
		
		var mob = mob_scene.instantiate()
		var mob_spawn_location = $Level/SpawnPath/SpawnLocation
		mob_spawn_location.progress_ratio = randf()	
	
		# Set the mob's position to a random location.
		mob.position = mob_spawn_location.position + $Level.position
		print (mob.position)

		# Spawn the mob by adding it to the Main scene.
		add_child(mob)

func add_kill():
	if hud == null : return
	hud.add_kill()

func save():
	if hud == null : return null
	
	var save_dict = {
		"best" : hud.get_best_score()
	}
	
	return save_dict

func load_game():
	if hud == null : return
	
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()	

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)	
		
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		var node_data = json.get_data()
		
		var best_score = node_data["best"]
		
		hud.set_best_score(best_score)
		
		print ("Best score : " + str (best_score))

func save_game():
	if hud == null : return

	var best_score = save()
	
	if best_score == null : return
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	var json_string = JSON.stringify(best_score)
	
	save_file.store_line(json_string)

func _exit_tree():
	save_game()
