extends RigidBody3D
@onready var camera_angle:Vector3 = Vector3(3,15,3)#Angle of the camera respect of the player
@onready var camera_des_pos:Vector3 = position + camera_angle#Desire camera position
## -F : Ciro, I need you to put the names of all $nodes into 
#a onready var, not only to know which one is calling, but also to 
#avoid having to change every single line-code when we(includes you) 
#have to move the nodes

var des_vel:Vector3#Desire velocity
var speed:int = 7
var aply_force:Vector3
var normal:Vector3#Normal of the floor

var last_pos_wheel:Vector3

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
	if $Ray_suelo.is_colliding():
		if des_vel != Vector3.ZERO:
			normal = $Ray_suelo.get_collision_normal(0)
			aply_force = normal.rotated(des_vel.normalized().rotated(Vector3.UP,-PI/2),-PI/2)*des_vel.length()
			aply_force.x = des_vel.x * (Vector3(aply_force.x,0,aply_force.z).length() / des_vel.length())
			aply_force.z = des_vel.z * (Vector3(aply_force.x,0,aply_force.z).length() / des_vel.length())
			apply_force((aply_force-linear_velocity)*2,Vector3.UP)
		else:
			apply_force(-linear_velocity*4,Vector3.UP)
	
	$Mouse_ray.global_position = $Camera3D.global_position
	$Mouse_ray.target_position = $Camera3D.project_ray_normal($Node2D.get_global_mouse_position()) * 5000
	$Mouse_ray.global_rotation = Vector3.ZERO
	if $Mouse_ray.is_colliding():
		des_look_point = $Mouse_ray.get_collision_point()
		var direction:Vector2 = Vector2(position.x,-position.z).direction_to(Vector2(des_look_point.x,-des_look_point.z))
		var angle:float = Vector2(0,1).rotated($MeshInstance3D.rotation.y).angle_to(direction)
		$MeshInstance3D.rotation.y += max(min(angle*delta*10,delta*7),-delta*7)
	
	apply_torque(-rotation*50*(max(mass/10,1)))
	
	if Input.is_key_pressed(KEY_SPACE) and get_contact_count() > 0:
		linear_velocity.y = min(10,linear_velocity.y+10)
		mass = 100
		await body_entered
		mass = 1
	
	camera_des_pos += (position *0.8 + des_look_point*0.2 + camera_angle + Vector3(linear_velocity.x,0,linear_velocity.z)/3 -camera_des_pos)*delta*5
	camera_des_pos = camera_des_pos.normalized() * min(camera_des_pos.length(),get_parent().terr_size-3)
	$Camera3D.global_position = camera_des_pos
	$Ray_suelo.global_rotation = Vector3.ZERO
	
	$MeshInstance3D/MeshInstance3D2.rotate_x(($MeshInstance3D/MeshInstance3D2.global_position - last_pos_wheel).z*2)
	$MeshInstance3D/MeshInstance3D2.rotate_z(-($MeshInstance3D/MeshInstance3D2.global_position - last_pos_wheel).x*2)
	last_pos_wheel = $MeshInstance3D/MeshInstance3D2.global_position
	$MeshInstance3D/MeshInstance3D2.global_position = $MeshInstance3D/Marker3D.global_position
