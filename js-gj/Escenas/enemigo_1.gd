extends CharacterBody2D
@onready var personaje:CharacterBody2D = get_tree().get_nodes_in_group("Jugador")[0]

var walk_speed:int = 100
var accel:float = 5
var speed:Vector2
var des_dir:Vector2
var aim_pos:Vector2
var aim_speed:int = 5

func _process(delta: float) -> void:
	des_dir = position.direction_to(personaje.position)
	velocity += (des_dir*walk_speed-velocity)*delta*accel
	move_and_slide()
	aim_pos += (position+velocity*50-aim_pos)*delta*aim_speed
	$MeshInstance2D.look_at(aim_pos)
