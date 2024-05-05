extends CharacterBody2D
class_name Enemy

var player
var hp = 1
var speed = 5

@onready var shape = $Polygon2D
static var count = 0
var startPos

@onready var prog_bar_container = $Node
@onready var life_bar = $Node/GenericBar as GenericBar

signal enemy_killed
signal enemies_all_dead

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	player = get_node("/root/world/Player")
	player.player_died.connect(player_died)
	
		
	# Save initial position
	startPos = position
	
	reset()
			
func _process(_delta):
	var direction = (player.position - position)
	direction = direction.normalized() * speed
	
	look_at(player.position)
	
	var _collision = move_and_collide(direction)
	
	# Éviter que la barre pivote
	prog_bar_container.rotation = -global_rotation
		


func _on_area_2d_area_entered(area):
	var area_name = area.get_parent().name
	
	#if area.get_parent() is Bullet:
		#print("A bullet!")
		
	if "Bullet" in area_name or "RigidBody2D" in area_name:
		hp -= 1;
		
		life_bar.update_value(hp, null)
		
		print(hp)
		if (hp <= 0):
			count -= 1
			enemy_killed.emit()
			
			get_tree().call_group("game_manager", "add_kill")
			
			print ("Enemies left : " + str(count))
			
			area.get_parent().queue_free()
			queue_free();
			
			if (count <= 0):
				enemies_all_dead.emit()
				get_tree().call_group("game_manager", "start_spawning")
				#var tmp = get_tree().call_deferred("reload_current_scene")

func player_died():
	count = 0

func reset():
	count += 1
	
	if (count > 5):
		hp = randi_range(1, 6)	
		
	match (hp):
		1:
			shape.color = Color(1, 1, 1)
		2:
			shape.color = Color(0, 0.8, 0)
		3:
			shape.color = Color(0, 0.8, 0)
		4:
			shape.color = Color(0, 0, 0.8)
		5:
			shape.color = Color(0.8, 0, 0)
			scale.x = 1.5
			scale.y = 1.5
		6:
			$MeGustaSmall.visible = true
			$Polygon2D.visible = false
			scale.x = 2
			scale.y = 2	
			
	life_bar.max_value = hp
	life_bar.value = hp
