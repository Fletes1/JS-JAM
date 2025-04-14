extends CharacterBody2D

var walk_speed:int = 100
var accel:float = 5
var des_dir:Vector2

var aiming:bool = false
var aim_pos:Vector2
var aim_speed:int = 5

func _process(delta: float) -> void:
	des_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		des_dir.y -= 1
	if Input.is_key_pressed(KEY_S):
		des_dir.y += 1
	if Input.is_key_pressed(KEY_D):
		des_dir.x += 1
	if Input.is_key_pressed(KEY_A):
		des_dir.x -= 1
	velocity += (des_dir*walk_speed-velocity)*delta*accel
	move_and_slide()
	aiming = Input.is_action_pressed("ui_mouse_Right")
	if aiming:
		aim_pos += (get_global_mouse_position()-aim_pos)*delta*aim_speed
	else:
		aim_pos += (position+velocity-aim_pos)*delta*aim_speed
	$MeshInstance2D.look_at(aim_pos)
	$MeshInstance2D2.global_position = aim_pos
