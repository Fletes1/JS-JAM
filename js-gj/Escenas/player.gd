extends RigidBody3D
@onready var camera_angle:Vector3 = Vector3(3,15,3)#Angle of the camera respect of the player
@onready var camera_des_pos:Vector3 = position + camera_angle#Desire camera position

var des_vel:Vector3#Desire velocity
var speed:int = 8

var des_look_point:Vector3#Desire look point

func _ready() -> void:
	$Camera3D.global_position = camera_des_pos
	$Camera3D.look_at(position)

func _physics_process(delta: float) -> void:
	des_vel = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		des_vel -= Vector3(0,0,1).rotated(Vector3.UP,$Camera3D.rotation.y)
	if Input.is_key_pressed(KEY_S):
		des_vel -= Vector3(0,0,-1).rotated(Vector3.UP,$Camera3D.rotation.y)
	if Input.is_key_pressed(KEY_D):
		des_vel -= Vector3(-1,0,0).rotated(Vector3.UP,$Camera3D.rotation.y)
	if Input.is_key_pressed(KEY_A):
		des_vel -= Vector3(1,0,0).rotated(Vector3.UP,$Camera3D.rotation.y)
	des_vel = des_vel.normalized()*speed
	if Input.is_key_pressed(KEY_SHIFT):
		des_vel *= 2
	apply_force(Vector3((des_vel-linear_velocity).x,0,(des_vel-linear_velocity).z),Vector3.UP)
	if des_vel == Vector3.ZERO:
		apply_force(Vector3((des_vel-linear_velocity).x,0,(des_vel-linear_velocity).z)*0.5,Vector3.UP)
	
	$Mouse_ray.global_position = $Camera3D.global_position
	$Mouse_ray.target_position = $Camera3D.project_ray_normal($Node2D.get_global_mouse_position()) * 5000
	$Mouse_ray.global_rotation = Vector3.ZERO
	if $Mouse_ray.is_colliding():
		des_look_point += ($Mouse_ray.get_collision_point()-des_look_point)*delta*10
		$MeshInstance3D.look_at(des_look_point)
		$MeshInstance3D.rotation.x = 0
		$MeshInstance3D.rotation.z = 0
	apply_torque(-rotation*30)
	
	if Input.is_key_pressed(KEY_SPACE) and get_contact_count() > 0:
		linear_velocity.y = min(10,linear_velocity.y+10)
		mass = 100
		await body_entered
		mass = 1
	
	camera_des_pos += (position *0.8 + des_look_point*0.2 + camera_angle + Vector3(linear_velocity.x,0,linear_velocity.z)/3 -camera_des_pos)*delta*5
	camera_des_pos = camera_des_pos.normalized() * min(camera_des_pos.length(),get_parent().terr_size-3)
	$Camera3D.global_position = camera_des_pos
