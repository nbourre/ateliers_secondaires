class_name Marqueur
extends CanvasLayer

@onready var sprite := $Sprite2D
@export var offset_from_edge := 30.0  # Distance du bord de l'écran

var target: Node2D = null
var player: Node2D = null
var viewport_size: Vector2

var sprite_dict : Dictionary = {
    "brown": "res://assets/sprites/meteorBrown_tiny1.png",
    "grey": "res://assets/sprites/meteorGrey_tiny1.png"
}

func _ready() -> void:
    viewport_size = get_viewport().size
    set_process(target != null)

func set_color(color: String) -> void:
    if sprite_dict.has(color):
        sprite.texture = load(sprite_dict[color])

func set_target(new_target: Node2D, new_player: Node2D) -> void:
    target = new_target
    player = new_player
    set_process(true)

func _process(_delta: float) -> void:
    if not target or not player:
        queue_free()
        return
    
    # Calculer la position du marqueur sur le segment joueur-météorite
    var direction = (target.global_position - player.global_position).normalized()
    var viewport_center = viewport_size / 2
    
    # Trouver le point d'intersection avec le bord de l'écran
    var marker_pos = _get_edge_position(direction, viewport_center)
    
    sprite.global_position = marker_pos
    
    # Orienter le sprite vers la météorite
    sprite.rotation = direction.angle()

# Calcule la position du marqueur au bord de l'écran
func _get_edge_position(direction: Vector2, viewport_center: Vector2) -> Vector2:
    var max_x = viewport_size.x / 2 - offset_from_edge
    var max_y = viewport_size.y / 2 - offset_from_edge
    
    # Déterminer quel bord atteindre
    if abs(direction.x) > abs(direction.y):
        # Bord gauche ou droit
        var x = sign(direction.x) * max_x
        var y = direction.y / direction.x * x
        y = clamp(y, -max_y, max_y)
        return viewport_center + Vector2(x, y)
    else:
        # Bord haut ou bas
        var y = sign(direction.y) * max_y
        var x = direction.x / direction.y * y
        x = clamp(x, -max_x, max_x)
        return viewport_center + Vector2(x, y)

func is_target_visible(camera_rect: Rect2) -> bool:
    return camera_rect.has_point(target.global_position)