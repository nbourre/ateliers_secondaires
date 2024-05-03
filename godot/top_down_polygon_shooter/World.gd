extends Node2D

@export var mob_scene : PackedScene
@onready var hud : HUD

func _ready():
	if has_node("HUD"):
		hud = $HUD

func start_spawning():
	if has_node("MobTimer"):
		$MobTimer.start()

func _on_mob_timer_timeout():
	if has_node("Level"):
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
	
