extends RigidBody3D
@onready var camera_angle:Vector3 = Vector3(3,7,3)
@onready var camera_des_pos:Vector3 = position + camera_angle
## -F : Ciro, I need you to put the names of all $nodes into 
#a onready var, not only to know which one is calling, but also to 
#avoid having to change every single line-code when we(includes you) 
#have to move the nodes


var des_vel:Vector3
var speed:int = 8

var des_look_point:Vector3
var rotacion_rueda:Vector3



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
	apply_force(Vector3((des_vel-linear_velocity).x,0,(des_vel-linear_velocity).z)*10,Vector3.UP)
	if des_vel == Vector3.ZERO:
		apply_force(Vector3((des_vel-linear_velocity).x,0,(des_vel-linear_velocity).z)*5,Vector3.UP)
	
	$Mouse_ray.global_position = $Camera3D.global_position
	$Mouse_ray.target_position = $Camera3D.project_ray_normal($Node2D.get_global_mouse_position()) * 5000
	$Mouse_ray.global_rotation = Vector3.ZERO
	if $Mouse_ray.is_colliding():
		des_look_point += ($Mouse_ray.get_collision_point()-des_look_point)*delta*10
		$MeshInstance3D.look_at(des_look_point)
		$MeshInstance3D.rotation.x = 0
		$MeshInstance3D.rotation.z = 0
	apply_torque(-rotation*300)
	
	if Input.is_key_pressed(KEY_SPACE) and get_contact_count() > 0:
		linear_velocity.y = 10
		mass = 50
		await body_entered
		mass = 10
	
	camera_des_pos += (position *0.8 + des_look_point*0.2 + camera_angle + Vector3(linear_velocity.x,0,linear_velocity.z)/3 -camera_des_pos)*delta*5
	$Camera3D.global_position = camera_des_pos
