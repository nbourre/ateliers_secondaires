extends KinematicBody2D

var player

var motion = Vector2()
var hp = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("Player")
	
	hp = int(rand_range(1, 5))
	match hp:
		1:
			$Sprite.modulate = Color(.75, .75, .75)
		2:
			$Sprite.modulate = Color(1, 1, 0)
		3:
			$Sprite.modulate = Color(0, 1, 0)
		4:
			$Sprite.modulate = Color(0, 1, 1)
		5:
			$Sprite.modulate = Color(1, 0, 0)
	

func _physics_process(_delta):
	var direction = (player.position - position)
	direction = direction.normalized() * 5.5

	position += direction
	look_at(player.position)

	var _collision = move_and_collide(motion)

	if hp <= 0:
		queue_free()


func _on_Area2D_body_entered(body:Node):
	if "Bullet" in body.name:
		hp -= 1
		
